local v_ver = [[ToggleConfig 2.0 Settings]]

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

--================================================--
-- ToggleConfig.lua
--================================================--

if getgenv().ToggleConfig then
	return getgenv().ToggleConfig
end

local HttpService = game:GetService("HttpService")

local PATH = "ExperienceSettings"
local FILE_NAME = PATH .. "/ToggleConfig.json"

local ToggleConfig = {
	Version = "1.0",
	Toggles = {},
	ID = {}
}

--------------------------------------------------
-- API
--------------------------------------------------

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

--------------------------------------------------
-- File Helpers
--------------------------------------------------

local function FolderExist(folder)
	local ok, result = pcall(function()
		return isfolder(folder)
	end)

	return ok and result
end

local function FileExist(file)
	local ok, result = pcall(function()
		return isfile(file)
	end)

	return ok and result
end

local function CreateFolder(folder)
	pcall(function()
		if makefolder then
			makefolder(folder)
		end
	end)
end

--------------------------------------------------
-- Save
--------------------------------------------------

function ToggleConfig:Save()

	if not writefile then
		warn("[ToggleConfig] writefile not supported.")
		return false
	end

	if not FolderExist(PATH) then
		CreateFolder(PATH)
	end

	local data = {
		Version = self.Version,
		Toggles = self.Toggles
	}

	local ok, err = pcall(function()

		writefile(
			FILE_NAME,
			HttpService:JSONEncode(data)
		)

	end)

	if not ok then
		warn("[ToggleConfig] Save Failed:", err)
		return false
	end

	return true

end

--------------------------------------------------
-- Load
--------------------------------------------------

function ToggleConfig:Load()

	if not FolderExist(PATH) then
		CreateFolder(PATH)
	end

	if not FileExist(FILE_NAME) then

		print("[ToggleConfig] First Launch. Creating Config...")

		self:Save()

		return

	end

	local ok, data = pcall(function()

		return HttpService:JSONDecode(
			readfile(FILE_NAME)
		)

	end)

	if ok and type(data) == "table" then

		self.Version = data.Version or self.Version
		self.Toggles = data.Toggles or {}

		print("[ToggleConfig] Loaded.")

	else

		warn("[ToggleConfig] Config Corrupted. Resetting...")

		self.Version = "1.0"
		self.Toggles = {}

		self:Save()

	end

end

--------------------------------------------------

ToggleConfig:Load()

getgenv().ToggleConfig = ToggleConfig

return ToggleConfig
