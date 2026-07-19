local v_ver = [[ToggleConfig 1.0 Settings]]

------------------------------------------------------------------------------------------

-- [ All Functions had been disabled | Reason: Not for the UI ]

--====== CLIENT SERVICES ======--

-- UI / Player Interface
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 3D/2D Destroy
local Debris = game:GetService("Debris")

-- 3D Wprkspace
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

---------------------------------------------------------------------------------------

-- getgenv 

if getgenv().ToggleConfig then
    return getgenv().ToggleConfig
end

local FILE_NAME = "ToggleConfig.json"

local ToggleConfig = {
    Version = "1.0",
    Toggles = {},
    ID = {}
}

-- API 

function ToggleConfig:Get(id, default)
    if self.Toggles[id] == nil then
        self.Toggles[id] = default
    end
    return self.Toggles[id]
end

function ToggleConfig:Set(id, value)
    self.Toggles[id] = value
end

function ToggleConfig:Exist(id)
    return self.Toggles[id] ~= nil
end

function ToggleConfig:Remove(id)
    self.Toggles[id] = nil
end

-- Load

ToggleConfig:Load()

getgenv().ToggleConfig = ToggleConfig

return ToggleConfig
