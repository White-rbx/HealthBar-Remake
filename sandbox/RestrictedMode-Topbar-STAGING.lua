-- ArcScriptCenter Restricted Mode — STAGING client UI gate.
-- Trusted account-bound moderation and API enforcement MUST remain server-side.
-- This only constrains the existing ExperienceSettings GUI for visual QA.
local env = type(getgenv) == "function" and getgenv() or nil
if not env or env.__ES_RESTRICTED_MODE ~= true
    or env.__ES_BAN_SELECTION ~= "restricted_mode"
    or env.__ES_BANNED == true then
    return false
end

local s = game:GetService("CoreGui")
local root = s:FindFirstChild("ExperienceSettings")
local menu = root and root:FindFirstChild("Menu")
local topbar = menu and menu:FindFirstChild("TopBar")
local holder = topbar and topbar:FindFirstChild("Holder")
if not holder then
    warn("[Restricted Mode] Missing original TopBar Holder")
    return false
end

local allowed = {
    ["a1_Open/Close"] = true,
    ["z7_About"] = true,
    ["z8_ChatGPT"] = true,  -- actual current Arcsen button
    ["z8_Arcsen"] = true,   -- forward-compatible name
}
local saved = setmetatable({}, { __mode = "k" })
local previous = env.ESRestrictedTopbarController
if type(previous) == "table" and type(previous.stop) == "function" then
    pcall(previous.stop)
end
local connections = {}
local stopped = false
local disabledColor = Color3.fromRGB(89, 89, 89)

local function lockButton(button)
    if stopped or not button:IsA("GuiButton") or (button.Parent == holder and allowed[button.Name]) then return end
    if not saved[button] then
        saved[button] = {
            interactable = button.Interactable,
            active = button.Active,
            autoColor = button.AutoButtonColor,
            color = button.BackgroundColor3
        }
    end
    button.Interactable = false
    button.Active = false
    button.AutoButtonColor = false
    button.BackgroundColor3 = disabledColor
end

local function watch(container)
    for _, button in ipairs(container:GetDescendants()) do
        lockButton(button)
    end
    table.insert(connections, container.DescendantAdded:Connect(function(child)
        lockButton(child)
    end))
    -- Buttons directly parented to Holder, including those added after startup.
    for _, child in ipairs(container:GetChildren()) do
        lockButton(child)
    end
end

watch(holder)
local more = topbar:FindFirstChild("TopButtons")
if more then watch(more) end
table.insert(connections, topbar.ChildAdded:Connect(function(child)
    if child.Name == "TopButtons" then watch(child) else lockButton(child) end
end))

local controller = {}
function controller.stop()
    if stopped then return end
    stopped = true
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    for button, state in pairs(saved) do
        if button and button.Parent then
            pcall(function()
                button.Interactable = state.interactable
                button.Active = state.active
                button.AutoButtonColor = state.autoColor
                button.BackgroundColor3 = state.color
            end)
        end
    end
    if env.ESRestrictedTopbarController == controller then
        env.ESRestrictedTopbarController = nil
    end
end
env.ESRestrictedTopbarController = controller
print("[ExperienceSettings] Restricted Mode TopBar and tools UI gate active (STAGING).")
return true
