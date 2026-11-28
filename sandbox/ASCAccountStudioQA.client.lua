-- Independent Studio QA adapter. A test place Loader can use the module directly.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runGate = require(ReplicatedStorage:WaitForChild("ASCAccountLoaderGate"))
local gate = script:WaitForChild("VerifiedLoaderSession")
local signOut = script:WaitForChild("SignOut")
local signOutConnection

local opened, reason = runGate({
    start = function(profile, logout)
        signOutConnection = signOut.Event:Connect(logout)
        gate:Fire(profile.status)
    end,
    update = function(profile)
        gate:Fire(profile.status)
    end,
    stop = function()
        signOutConnection:Disconnect()
        gate:Fire(false)
    end,
})
if not opened and reason ~= "cancelled" then warn("ESLogin QA gate stopped", reason) end
