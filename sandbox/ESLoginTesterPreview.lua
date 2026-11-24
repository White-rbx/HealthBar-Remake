-- ArcScriptCenter ESLogin tester preview | STAGING UI ONLY
-- Authorized local UI tester ID: 8728964745.
-- This client-side check is a convenience gate, NOT server authentication.
-- Never issue an account session, create a pairing, or bypass Account QA.
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
if not localPlayer or localPlayer.UserId ~= 8728964745 then
    warn("[ESLogin Tester] This UI preview is reserved for the configured tester.")
    return false
end

local base = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/"
local testerClient = {
    -- The live QA site deliberately remains locked. Do not claim /signin is active yet.
    website = "https://arcscriptcenter-account-qa.kogpasan14.workers.dev/signin",
    isolatedQA = true,
    accountMode = false,
    testerPreview = true,
}
function testerClient.canRemember() return false end
function testerClient.hasSession() return false end
function testerClient.refresh() return nil, "tester_preview_only" end
function testerClient.profile() return nil end
function testerClient.begin() return nil, "tester_preview_only" end
function testerClient.poll()
    error("Tester UI preview must never initiate an account pairing")
end

local ok, result = pcall(function()
    local source = game:HttpGet(base .. "ESLogin.lua")
    local login = assert(loadstring(source))
    return login(testerClient, nil, "tester_preview_only")
end)
if not ok then
    warn("[ESLogin Tester] UI preview failed: " .. tostring(result))
end
-- The tester can inspect the UI, website handoff, and X button, but cannot
-- advance the ExperienceSettings main loader without a verified account session.
return false
