-- STAGING Tester ID 8728964745: preview ESLogin UI without enabling Account QA.
-- This is not a trusted identity token and cannot authenticate to Cloudflare.
local source = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua"
return assert(loadstring(game:HttpGet(source)))("account_qa_tester")
