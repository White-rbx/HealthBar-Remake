-- Opt-in isolated Account QA. Default and production entrypoints stay unchanged.
local source = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua"
return assert(loadstring(game:HttpGet(source)))("account_qa")
