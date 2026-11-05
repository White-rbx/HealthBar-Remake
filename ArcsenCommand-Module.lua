--[[
    ArcsenCommand-Module.lua
    Version: 0.6.2

    Purpose:
      - Command core only; creates no UI.
      - Publishes its API through getgenv().ArcsenCommand.
      - First migrated command: /HereChat ON, /HereChat OFF, /HereChat STATUS.
      - Sends output to Arcsen through setOutput(callback).

    Load this trusted file before Arcsen tries to use it.
    This is an executor-side script, not a standard Roblox ModuleScript.
]]

local getEnvironment = getgenv
if type(getEnvironment) ~= "function" then
    error("ArcsenCommand requires an executor that provides getgenv().", 0)
end

local sharedEnvironment = getEnvironment()
if type(sharedEnvironment) ~= "table" then
    error("ArcsenCommand could not access the shared executor environment.", 0)
end

-- Clean up a previous copy, if this file is executed again.
local previous = sharedEnvironment.ArcsenCommand
if type(previous) == "table" and type(previous.destroy) == "function" then
    pcall(previous.destroy)
end

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local module = {
    version = "0.6.2",
    APIVersion = 1,
    commands = {},
    _output = nil,
    _onCommandsChanged = nil,
    _onHereChatChanged = nil,
    _hereChatEnabled = false,
    _openChatEnabled = false,
    _openChatCycle = 0,
    _openChatLastID = 0,
    _openChatSessionID = HttpService:GenerateGUID(false):gsub("-", ""),
    _onOpenChatChanged = nil,
    _openChatPollInterval = 6,
    _openChatLimit = 125,
    _connections = {},
    _lastMessageKey = nil,
    _lastMessageAt = 0,
    _pendingOutgoing = {},
    _destroyed = false,
    _placeId = tonumber(game.PlaceId) or 0,
    _universeId = tonumber(game.GameId) or 0,
    _experienceName = "Place " .. tostring(tonumber(game.PlaceId) or 0),
    _experienceNameReady = false,
}

-- Resolve the current PlaceId to a readable Roblox place/experience name.
-- The ID fallback is kept until MarketplaceService returns a name successfully.
task.spawn(function()
    if module._placeId <= 0 then return end
    local ok, productInfo = pcall(function()
        return MarketplaceService:GetProductInfo(module._placeId, Enum.InfoType.Asset)
    end)
    if ok and type(productInfo) == "table" and type(productInfo.Name) == "string" and productInfo.Name:match("%S") then
        module._experienceName = productInfo.Name
        module._experienceNameReady = true
    end
end)

local function safeDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function emit(message, level, metadata)
    message = tostring(message or "")
    level = tostring(level or "info")
    metadata = type(metadata) == "table" and metadata or {}

    if type(module._output) == "function" then
        local ok = pcall(module._output, message, level, metadata)
        if ok then
            return
        end
    end

    -- Fallback if Arcsen has not connected its output callback yet.
    warn("[ArcsenCommand] " .. message)
end

function module.setOutput(callback)
    if callback ~= nil and type(callback) ~= "function" then
        return false, "Output callback must be a function or nil."
    end

    module._output = callback
    return true
end

function module.setOnCommandsChanged(callback)
    if callback ~= nil and type(callback) ~= "function" then
        return false, "Command-change callback must be a function or nil."
    end

    module._onCommandsChanged = callback
    return true
end

function module.setOnHereChatChanged(callback)
    if callback ~= nil and type(callback) ~= "function" then
        return false, "HereChat callback must be a function or nil."
    end

    module._onHereChatChanged = callback
    return true
end

local function notifyHereChatChanged(enabled)
    if type(module._onHereChatChanged) == "function" then
        pcall(module._onHereChatChanged, enabled == true)
    end
end

-- OpenChat is a read-only public feed of developer-approved announcements.
-- Do not use external HTTP to exchange player-to-player messages; Roblox
-- requires TextChatService for player chat and its permission/filter rules.
function module.setOnOpenChatChanged(callback)
    if callback ~= nil and type(callback) ~= "function" then
        return false, "OpenChat callback must be a function or nil."
    end
    module._onOpenChatChanged = callback
    return true
end

local function notifyOpenChatChanged(enabled)
    if type(module._onOpenChatChanged) == "function" then
        pcall(module._onOpenChatChanged, enabled == true)
    end
end

local getSenderColor

local function openChatURL()
    -- Official ArcScriptCenter API is the default; localhost was a prototype.
    local base = tostring(sharedEnvironment.ArcsenOpenChatURL
        or "https://arcscriptcenter-api.kogpasan14.workers.dev")
    base = base:gsub("/+$", "")
    if not (base:match("^https://[%w%.%-]+$")
        or base:match("^https://[%w%.%-]+:%d+$")) then
        return nil, "OpenChat requires an HTTPS API base URL."
    end
    return base .. "/api/v1/openchat/messages"
end

local function openChatHTTP(method, after)
    if method ~= "GET" then
        return nil, "Cloud OpenChat is read-only. Use Roblox TextChatService for player chat."
    end
    local url, reason = openChatURL()
    if not url then return nil, reason end
    url = url .. "?after=" .. tostring(math.max(0, math.floor(tonumber(after) or 0)))

    local function decode(body)
        local ok, result = pcall(HttpService.JSONDecode, HttpService, tostring(body or ""))
        if not ok or type(result) ~= "table" then
            return nil, "Invalid JSON from ArcScriptCenter API."
        end
        if result.ok ~= true or type(result.messages) ~= "table" then
            return nil, tostring(result.error or "OpenChat API did not return messages.")
        end
        if result.mode ~= "admin_announcements" then
            return nil, "Unexpected OpenChat API mode."
        end
        return result
    end

    local function safeHttpGet()
        -- Some supported hosts expose game:HttpGet but not request() StatusCode.
        local success, body = pcall(function() return game:HttpGet(url) end)
        if not success then return nil, tostring(body) end
        return decode(body)
    end

    local requestFn = type(request) == "function" and request
        or type(http_request) == "function" and http_request
        or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
        or (type(http) == "table" and type(http.request) == "function" and http.request)
        or (type(sharedEnvironment.request) == "function" and sharedEnvironment.request)
    if type(requestFn) ~= "function" then return safeHttpGet() end

    local ok, reply = pcall(requestFn, {
        Url = url, Method = "GET",
        Headers = {["Accept"] = "application/json"}
    })
    if not ok or type(reply) ~= "table" then
        local data, fallbackError = safeHttpGet()
        if data then return data end
        return nil, "OpenChat request failed: " .. tostring(ok and "unexpected response" or reply)
            .. "; HttpGet: " .. tostring(fallbackError)
    end

    local code = tonumber(reply.StatusCode or reply.Status or 0) or 0
    if code == 0 then
        local data, fallbackError = safeHttpGet()
        if data then return data end
        return nil, "OpenChat HTTP 0 (transport/network error). HttpGet: " .. tostring(fallbackError)
    end
    if code < 200 or code >= 300 then
        local valid, data = pcall(HttpService.JSONDecode, HttpService, tostring(reply.Body or ""))
        return nil, "OpenChat HTTP " .. tostring(code) .. ": "
            .. tostring(valid and type(data) == "table" and data.error or "Request rejected")
    end
    return decode(reply.Body)
end

local function deliverOpenChat(messages)
    if type(messages) ~= "table" then return end
    local received = {}
    for _, item in ipairs(messages) do
        if type(item) == "table" then
            local id = math.floor(tonumber(item.id) or 0)
            local body = tostring(item.text or "")
            if id > module._openChatLastID and body ~= "" then
                module._openChatLastID = id
                local username = tostring(item.username or "Unknown")
                local localPlayer = Players.LocalPlayer
                local isMine = localPlayer ~= nil and username == localPlayer.Name
                local red, green, blue = getSenderColor(username)
                table.insert(received, {
                    body = body, id = id, username = username,
                    displayName = tostring(item.displayName or username),
                    timestamp = (function()
                        local numeric = tonumber(item.timestamp)
                        if numeric then return numeric end
                        if type(item.timestamp) == "string" then
                            local iso = item.timestamp:gsub(" ", "T")
                            if iso:match("^%d%d%d%d%-%d%d%-%d%dT") and not iso:match("Z$") then
                                iso = iso .. "Z"
                            end
                            local ok, dt = pcall(DateTime.fromIsoDate, iso)
                            if ok and dt then return dt.UnixTimestamp end
                        end
                        return os.time()
                    end)(),
                    direction = isMine and "Right" or "Left",
                    r = red, g = green, b = blue,
                })
            end
        end
    end
    for index, entry in ipairs(received) do
        emit(entry.body, "chat", {
                    source = "OpenChat", origin = "Global",
                    batchIndex = index, batchTotal = #received,
                    direction = entry.direction,
                    username = entry.username,
                    displayName = entry.displayName,
                    messageId = entry.id,
                    timestamp = entry.timestamp,
                    experienceName = "OpenChat • Global",
                    r = entry.r, g = entry.g, b = entry.b,
                    copyable = true,
                })
    end
end

function module.setOpenChat(enabled)
    if module._destroyed then return false, "ArcsenCommand has been destroyed." end
    enabled = enabled == true
    if module._openChatEnabled == enabled then
        local message = "OpenChat already " .. (enabled and "ON" or "OFF")
        emit(message, "info", {source="ArcsenCommand", isSystem=true})
        return true, message
    end
    if not enabled then
        module._openChatEnabled = false
        module._openChatCycle = module._openChatCycle + 1
        notifyOpenChatChanged(false)
        emit("OpenChat: OFF", "success", {source="ArcsenCommand", isSystem=true})
        return true, "OpenChat OFF"
    end
    -- Confirm the API is reachable before enabling or creating a tab.
    local data, err = openChatHTTP("GET", module._openChatLastID)
    if not data then return false, err end
    module._openChatEnabled = true
    module._openChatCycle = module._openChatCycle + 1
    local cycle = module._openChatCycle
    notifyOpenChatChanged(true)
    deliverOpenChat(data.messages)
    emit("OpenChat: ON (read-only Cloud Feed; max " .. tostring(module._openChatLimit) .. " announcements)",
        "success", {source="ArcsenCommand", isSystem=true})
    task.spawn(function()
        while module._openChatEnabled and not module._destroyed and cycle == module._openChatCycle do
            task.wait(module._openChatPollInterval)
            if not module._openChatEnabled or module._destroyed or cycle ~= module._openChatCycle then break end
            local response = openChatHTTP("GET", module._openChatLastID)
            if module._openChatEnabled and not module._destroyed and cycle == module._openChatCycle and response then
                deliverOpenChat(response.messages)
            end
        end
    end)
    return true, "OpenChat ON"
end

function module.isOpenChatEnabled()
    return module._openChatEnabled == true
end

function module.sendOpenChat(rawText)
    return false, "OpenChat Cloud Feed is read-only. Player chat must use Roblox TextChatService (try HereChat in a supported experience)."
end

-- Moderation-only endpoint: a report is not a chat message.
-- Anonymous reporter ID is random per ArcsenCommand session; user names are
-- neither requested nor transmitted by this function.
function module.reportOpenChat(messageId, reason, details)
    if module._destroyed then return false, "ArcsenCommand has been destroyed." end
    messageId = tonumber(messageId)
    if not messageId or messageId < 1 or messageId % 1 ~= 0 then
        return false, "Invalid message ID."
    end
    local accepted = {harassment=true, spam=true, abuse=true, other=true}
    if accepted[tostring(reason)] ~= true then return false, "Invalid report reason." end
    details = tostring(details or ""):sub(1, 240)
    local url, err = openChatURL()
    if not url then return false, err end
    url = url:gsub("/messages$", "/reports")
    local req = type(request) == "function" and request
        or type(http_request) == "function" and http_request
        or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
        or (type(http) == "table" and type(http.request) == "function" and http.request)
        or (type(sharedEnvironment.request) == "function" and sharedEnvironment.request)
    if type(req) ~= "function" then return false, "This environment cannot send report requests." end
    local body = HttpService:JSONEncode({
        messageId = messageId,
        reason = reason,
        details = details,
        reporterToken = module._openChatSessionID
    })
    local ok, response = pcall(req, {
        Url = url, Method = "POST",
        Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
        Body = body
    })
    if not ok or type(response) ~= "table" then
        return false, "Report network request failed."
    end
    local code = tonumber(response.StatusCode or response.Status or 0) or 0
    local decodedOK, data = pcall(HttpService.JSONDecode, HttpService, tostring(response.Body or ""))
    if code >= 200 and code < 300 and decodedOK and type(data)=="table" and data.ok then
        return true, "Report accepted"
    end
    return false, decodedOK and type(data)=="table" and tostring(data.error or "Report rejected")
        or ("Report HTTP " .. tostring(code))
end

local function notifyCommandsChanged()
    if type(module._onCommandsChanged) == "function" then
        pcall(module._onCommandsChanged, module.commands)
    end
end

local function disconnectHereChat()
    for index = #module._connections, 1, -1 do
        safeDisconnect(module._connections[index])
        module._connections[index] = nil
    end
end

local function plainText(value)
    -- The Arcsen callback should render this as plain text (RichText = false).
    return tostring(value or "")
end

local function getPlayerByName(name)
    -- Prefer the exact account username before trying a non-unique DisplayName.
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == name then
            return player
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == name then
            return player
        end
    end
    return nil
end

getSenderColor = function(name)
    -- Stable, readable color for the whole incoming-message bubble.
    local seed = 0
    name = tostring(name or "")
    for index = 1, #name do
        seed = (seed + string.byte(name, index)) % 2147483647
    end

    local red = (seed * 123) % 200 + 55
    local green = (seed * 321) % 200 + 55
    local blue = (seed * 213) % 200 + 55
    local brightest = math.max(red, green, blue)

    if brightest < 120 and brightest > 0 then
        local scale = 120 / brightest
        red = math.clamp(red * scale, 0, 255)
        green = math.clamp(green * scale, 0, 255)
        blue = math.clamp(blue * scale, 0, 255)
    end

    return math.floor(red), math.floor(green), math.floor(blue)
end

local function isDuplicate(username, text)
    local key = tostring(username) .. "\0" .. tostring(text)
    local now = os.clock()

    -- The new and legacy chat APIs can report the same message nearly at once.
    -- Keep this window short so repeated identical messages are not hidden for seconds.
    if key == module._lastMessageKey and (now - module._lastMessageAt) < 0.35 then
        return true
    end

    module._lastMessageKey = key
    module._lastMessageAt = now
    return false
end

local function hasPendingOutgoing()
    return #module._pendingOutgoing > 0
end

local function finishTemporaryChatHooks()
    if not module._hereChatEnabled and not hasPendingOutgoing() then
        disconnectHereChat()
    end
end

local function claimOutgoingEcho(username, text, player)
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return false
    end

    if player and player ~= localPlayer then
        return false
    end
    if tostring(username or "") ~= localPlayer.Name then
        return false
    end

    local now = os.clock()
    for index = #module._pendingOutgoing, 1, -1 do
        local pending = module._pendingOutgoing[index]
        if now - (tonumber(pending.at) or 0) > 15 then
            table.remove(module._pendingOutgoing, index)
        end
    end

    if #module._pendingOutgoing == 0 then
        finishTemporaryChatHooks()
        return false
    end

    -- Prefer an exact text match, but fall back to queue order if Roblox filtering
    -- transformed the text before the echo reached this client.
    for index, pending in ipairs(module._pendingOutgoing) do
        if tostring(pending.text or "") == tostring(text or "") then
            table.remove(module._pendingOutgoing, index)
            return true
        end
    end
    table.remove(module._pendingOutgoing, 1)
    return true
end

local function showIncomingMessage(username, text, player)
    if module._destroyed then
        return
    end

    username = tostring(username or "Unknown")
    text = tostring(text or "")
    if text == "" then
        return
    end

    if not player and Players.LocalPlayer and username == Players.LocalPlayer.Name then
        player = Players.LocalPlayer
    end

    local sentFromArcsen = claimOutgoingEcho(username, text, player)
    -- HereChat OFF suppresses ordinary incoming messages, but a pending message sent
    -- through Arcsen must still be able to return through Roblox's filtered chat event.
    if not module._hereChatEnabled and not sentFromArcsen then
        return
    end

    if sentFromArcsen then
        -- Always display the outgoing echo, even if the same text was received
        -- moments earlier; still remember it so the other chat API's duplicate is dropped.
        module._lastMessageKey = tostring(username) .. "\0" .. tostring(text)
        module._lastMessageAt = os.clock()
    elseif isDuplicate(username, text) then
        finishTemporaryChatHooks()
        return
    end

    local red, green, blue = getSenderColor(username)
    local teamName = nil
    local teamRed, teamGreen, teamBlue = nil, nil, nil
    local userId = nil

    if player then
        userId = player.UserId
        local team = player.Team
        if team then
            teamName = team.Name
            local teamColor = team.TeamColor.Color
            teamRed = math.floor(teamColor.R * 255 + 0.5)
            teamGreen = math.floor(teamColor.G * 255 + 0.5)
            teamBlue = math.floor(teamColor.B * 255 + 0.5)
            -- Keep sender accent separate. Arcsen renders the team name with these
            -- dedicated team RGB values, so the whole header/body need not be recolored.
        end
    end

    -- Arcsen owns the header layout. Send structured sender metadata and keep
    -- the message body as plain text; never add AI-Thinking-style [tags].
    emit(plainText(text), "chat", {
        source = "HereChat",
        origin = sentFromArcsen and "Arcsen" or "Roblox",
        direction = sentFromArcsen and "Right" or "Left",
        username = player and player.Name or username,
        displayName = player and player.DisplayName or username,
        userId = userId,
        teamName = teamName,
        experienceName = tostring(module._experienceName or ("Place " .. tostring(module._placeId))),
        placeId = module._placeId,
        universeId = module._universeId,
        teamR = teamRed,
        teamG = teamGreen,
        teamB = teamBlue,
        r = red,
        g = green,
        b = blue,
        isSystem = false,
        copyable = true,
    })
    finishTemporaryChatHooks()
end

local function connectNewChat()
    local ok, connection = pcall(function()
        return TextChatService.MessageReceived:Connect(function(message)
            if module._destroyed then
                return
            end

            local textSource = message and message.TextSource
            if not textSource then
                return
            end

            local username = textSource.Name or "Unknown"
            local userId = tonumber(textSource.UserId)
            local player = userId and Players:GetPlayerByUserId(userId) or nil
            showIncomingMessage(username, message.Text, player)
        end)
    end)

    if ok and connection then
        table.insert(module._connections, connection)
    end
end

local function connectLegacyChat()
    local ok, connection = pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local event = chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if not event then
            return nil
        end

        return event.OnClientEvent:Connect(function(messageData)
            if module._destroyed then
                return
            end
            if type(messageData) ~= "table" then
                return
            end
            if not messageData.FromSpeaker or not messageData.Message then
                return
            end

            local username = tostring(messageData.FromSpeaker)
            local player = getPlayerByName(username)
            showIncomingMessage(username, messageData.Message, player)
        end)
    end)

    if ok and connection then
        table.insert(module._connections, connection)
    end
end

function module.setHereChat(enabled)
    if module._destroyed then
        return false, "ArcsenCommand has been destroyed. Load the module again."
    end

    enabled = enabled == true
    if module._hereChatEnabled == enabled then
        local result = "HereChat already " .. (enabled and "ON" or "OFF")
        emit(result, "info", {source = "ArcsenCommand", isSystem = true})
        return true, result
    end

    module._hereChatEnabled = enabled
    if enabled then
        disconnectHereChat()
        connectNewChat()
        connectLegacyChat()
        emit("HereChat: ON", "success", {source = "ArcsenCommand", isSystem = true})
        notifyHereChatChanged(true)
    else
        if not hasPendingOutgoing() then
            disconnectHereChat()
        end
        emit("HereChat: OFF", "success", {source = "ArcsenCommand", isSystem = true})
        notifyHereChatChanged(false)
    end

    return true, "HereChat " .. (enabled and "ON" or "OFF")
end

function module.isHereChatEnabled()
    return module._hereChatEnabled == true
end

function module.sendMessage(rawText)
    if module._destroyed then
        return false, "ArcsenCommand has been destroyed."
    end

    local text = tostring(rawText or "")
    if not text:match("%S") then
        return false, "Message is empty."
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return false, "LocalPlayer is not available."
    end

    -- Register before sending so the server-filtered echo can be recognized as an
    -- Arcsen-originated message and displayed on the right exactly once.
    local pending = {text = text, at = os.clock()}
    table.insert(module._pendingOutgoing, pending)
    if #module._connections == 0 then
        connectNewChat()
        connectLegacyChat()
    end

    local ok, sendError = pcall(function()
        local channels = TextChatService:FindFirstChild("TextChannels")
        local general = channels and channels:FindFirstChild("RBXGeneral")
        if general and general:IsA("TextChannel") then
            general:SendAsync(text)
            return
        end

        local legacy = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local request = legacy and legacy:FindFirstChild("SayMessageRequest")
        if request and request:IsA("RemoteEvent") then
            request:FireServer(text, "All")
            return
        end

        error("No supported public Roblox chat channel is available.")
    end)

    if not ok then
        for index = #module._pendingOutgoing, 1, -1 do
            if module._pendingOutgoing[index] == pending then
                table.remove(module._pendingOutgoing, index)
                break
            end
        end
        finishTemporaryChatHooks()
        return false, tostring(sendError)
    end

    -- If Roblox never returns an echo, expire this pending entry and release the
    -- temporary listeners when HereChat is OFF. No unfiltered local bubble is faked.
    task.delay(15, function()
        for index = #module._pendingOutgoing, 1, -1 do
            if module._pendingOutgoing[index] == pending then
                table.remove(module._pendingOutgoing, index)
                break
            end
        end
        finishTemporaryChatHooks()
    end)

    return true, "Message submitted to Roblox chat."
end

function module.registerCommand(name, handler, description)
    name = tostring(name or ""):lower():gsub("^/", "")
    if name == "" then
        return false, "Command name is empty."
    end
    if type(handler) ~= "function" then
        return false, "Command handler must be a function."
    end

    module.commands[name] = {
        handler = handler,
        description = tostring(description or "No description provided."),
    }
    notifyCommandsChanged()
    return true
end

module.registerCommand("herechat", function(arguments)
    local option = tostring(arguments or ""):lower():match("^%s*(%S*)") or ""

    if option == "on" then
        local ok, result = module.setHereChat(true)
        if not ok then
            emit(result, "error", {source = "ArcsenCommand", isSystem = true})
        end
        return true, result
    elseif option == "off" then
        local ok, result = module.setHereChat(false)
        if not ok then
            emit(result, "error", {source = "ArcsenCommand", isSystem = true})
        end
        return true, result
    elseif option == "status" then
        local result = "HereChat: " .. (module.isHereChatEnabled() and "ON" or "OFF")
        emit(result, "info", {source = "ArcsenCommand", isSystem = true})
        return true, result
    end

    local usage = "Usage: /HereChat ON | OFF | STATUS"
    emit(usage, "warning", {source = "ArcsenCommand", isSystem = true})
    return true, usage
end, "Toggle incoming chat display: /HereChat ON, OFF, or STATUS")

module.registerCommand("openchat", function(arguments)
    local option = tostring(arguments or ""):lower():match("^%s*(%S*)") or ""
    if option == "on" or option == "off" then
        local ok, message = module.setOpenChat(option == "on")
        if not ok then emit(message, "error", {source="ArcsenCommand", isSystem=true}) end
        return true, message
    elseif option == "status" then
        local message = "OpenChat: " .. (module.isOpenChatEnabled() and "ON" or "OFF")
            .. " (read-only announcements, max 125, refresh every 6s)"
        emit(message, "info", {source="ArcsenCommand", isSystem=true})
        return true, message
    end
    local usage = "Usage: /OpenChat ON | OFF | STATUS"
    emit(usage, "warning", {source="ArcsenCommand", isSystem=true})
    return true, usage
end, "Read approved global announcements (read-only): ON, OFF or STATUS")

module.registerCommand("help", function()
    local names = {}
    for name in pairs(module.commands) do
        table.insert(names, "/" .. name)
    end
    table.sort(names)
    local message = "Available commands: " .. table.concat(names, ", ")
    emit(message, "info", {source = "ArcsenCommand", isSystem = true})
    return true, message
end, "List commands registered with ArcsenCommand")

function module.handleCommand(command, outputCallback)
    if type(outputCallback) == "function" then
        module.setOutput(outputCallback)
    end

    if module._destroyed then
        return false, "ArcsenCommand has been destroyed."
    end

    command = tostring(command or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local name, arguments = command:match("^/(%S+)%s*(.*)$")
    if not name then
        return false, "Not a command."
    end

    name = name:lower()
    local item = module.commands[name]
    if not item then
        local errorMessage = "Unknown command: /" .. name .. " (try /help)"
        emit(errorMessage, "error", {source = "ArcsenCommand", isSystem = true})
        return true, errorMessage
    end

    local ok, handled, result = pcall(item.handler, arguments, command)
    if not ok then
        local errorMessage = "Command /" .. name .. " failed: " .. tostring(handled)
        emit(errorMessage, "error", {source = "ArcsenCommand", isSystem = true})
        return true, errorMessage
    end

    return handled ~= false, result
end

function module.destroy()
    if module._destroyed then
        return
    end

    module._destroyed = true
    module._hereChatEnabled = false
    module._openChatEnabled = false
    module._openChatCycle = module._openChatCycle + 1
    table.clear(module._pendingOutgoing)
    disconnectHereChat()
    if sharedEnvironment.ArcsenCommand == module then
        sharedEnvironment.ArcsenCommand = nil
    end
end

sharedEnvironment.ArcsenCommand = module
return module
