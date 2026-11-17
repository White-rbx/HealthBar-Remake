-- Stage 16.79 reference for standalone Arcsen v7.3.43 client
-- No authentication occurs here. The actual UI is in the generated STAGING Lua artifact.
local M = {}
M.Status = {
    not_appealed = {layoutOrder = 0, color = Color3.fromRGB(40, 90, 175), section = "Review"},
    reviewing    = {layoutOrder = 1, color = Color3.fromRGB(180, 105, 30), section = "Review"},
    denied       = {layoutOrder = 2, color = Color3.fromRGB(155, 45, 45), section = "Denied"},
    approved     = {layoutOrder = 3, color = Color3.fromRGB(35, 135, 70), section = "Approved"},
}
function M.select(status) return M.Status[status] end
function M.canAppeal(status, serverCanAppealAgain)
    if status == "not_appealed" then return true end
    if status == "denied" then return serverCanAppealAgain == true end
    return false -- Reviewing/Approved cannot send repeat appeals.
end
function M.hasTrustedHistory(serverIdentityVerified, entries)
    -- This flag must come from a trusted server session, not a Lua client claim.
    return serverIdentityVerified == true and type(entries) == "table" and #entries > 0
end
return M
