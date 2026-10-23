--[[
    ArcsenCommand-Module.lua
    Version: 0.5.2

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

local module = {
    version = "0.5.2",
    APIVersion = 1,
    commands = {},
    _output = nil,
    _onCommandsChanged = nil,
    _onHereChatChanged = nil,
    _hereChatEnabled = false,
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

local function getSenderColor(name)
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
    table.clear(module._pendingOutgoing)
    disconnectHereChat()
    if sharedEnvironment.ArcsenCommand == module then
        sharedEnvironment.ArcsenCommand = nil
    end
end

sharedEnvironment.ArcsenCommand = module
return module
