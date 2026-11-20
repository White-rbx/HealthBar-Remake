-- Universal Banned Check Center QA entrypoint. Use "roblox_server" only for
-- the separate, account-verified smoke in an owner-controlled test experience.
local mode = (...) == "roblox_server" and "roblox_server" or "public_qa"
local env = getgenv()
if env.__ES_BOOTSTRAP_BUSY then return end
env.__ASC_BAN_V2_PREVIEW = true
local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua"
local ok, result = pcall(function() return assert(loadstring(game:HttpGet(url)))(mode) end)
env.__ASC_BAN_V2_PREVIEW = nil
if not ok then warn("[ASC Ban Preview] Loader could not start:", result) end
return ok and result
