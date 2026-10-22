--[[
    ArcsenCommand-Module.lua
    Version: 0.1.0

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

local module = {
    version = "0.1.0",
    commands = {},
    _output = nil,
    _hereChatEnabled = false,
    _connections = {},
    _lastMessageKey = nil,
    _lastMessageAt = 0,
    _destroyed = false,
}

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

local function playerLabel(player, fallbackName)
    if not player then
        return "@" .. plainText(fallbackName or "Unknown")
    end

    local label = "@" .. plainText(player.Name)
    if player.DisplayName ~= player.Name then
        label = label .. " (" .. plainText(player.DisplayName) .. ")"
    end

    if player.Team then
        label = "[" .. plainText(player.Team.Name) .. "] " .. label
    end

    return label
end

local function getPlayerByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == name or player.DisplayName == name then
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

    -- The new and legacy chat APIs can report the same message close together.
    if key == module._lastMessageKey and (now - module._lastMessageAt) < 2 then
        return true
    end

    module._lastMessageKey = key
    module._lastMessageAt = now
    return false
end

local function showIncomingMessage(username, text, player)
    if not module._hereChatEnabled or module._destroyed then
        return
    end

    username = tostring(username or "Unknown")
    text = tostring(text or "")
    if text == "" then
        return
    end

    if player and player == Players.LocalPlayer then
        return
    end

    if isDuplicate(username, text) then
        return
    end

    local red, green, blue = getSenderColor(username)
    local message = playerLabel(player, username) .. ": " .. plainText(text)

    emit(message, "chat", {
        source = "HereChat",
        username = username,
        r = red,
        g = green,
        b = blue,
        isSystem = false,
    })
end

local function connectNewChat()
    local ok, connection = pcall(function()
        return TextChatService.MessageReceived:Connect(function(message)
            if not module._hereChatEnabled or module._destroyed then
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
            if not module._hereChatEnabled or module._destroyed then
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
    disconnectHereChat()

    if enabled then
        connectNewChat()
        connectLegacyChat()
        emit("HereChat: ON", "success", {source = "ArcsenCommand", isSystem = true})
    else
        emit("HereChat: OFF", "success", {source = "ArcsenCommand", isSystem = true})
    end

    return true, "HereChat " .. (enabled and "ON" or "OFF")
end

function module.isHereChatEnabled()
    return module._hereChatEnabled == true
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
    disconnectHereChat()
    if sharedEnvironment.ArcsenCommand == module then
        sharedEnvironment.ArcsenCommand = nil
    end
end

sharedEnvironment.ArcsenCommand = module
return module
