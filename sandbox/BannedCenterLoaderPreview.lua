-- Dedicated Banned Check Center QA entrypoint. The regular Feedback Preview keeps
-- its existing startup. Only the approved test experience installs the bridge.
local env = getgenv()
if env.__ES_BOOTSTRAP_BUSY then return end
env.__ASC_BAN_V2_PREVIEW = true
local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua"
local ok, result = pcall(function() return assert(loadstring(game:HttpGet(url)))() end)
env.__ASC_BAN_V2_PREVIEW = nil
if not ok then warn("[ASC Ban Preview] Loader could not start:", result) end
return ok and result
