-- ArcScriptCenter WarningUI Actions v0.5.13
-- Load AFTER WarningUI.lua, BEFORE WarningUI_CloudConnector.lua.
-- Add only actions intentionally written and reviewed by the ExperienceSettings developer.

local ui = type(getgenv) == "function" and getgenv().WarningUI
assert(type(ui) == "table" and type(ui.registerScript) == "function", "Load WarningUI.lua first")

-- Example: Admin can set Button1/2 RequireScript, script ID = OpenHelp.
ui.registerScript("OpenHelp", function(warning)
  pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
      Title = "ExperienceSettings Help",
      Text = "Check ExperienceSettings for additional information.",
      Duration = 6
    })
  end)
end)

-- Optional second action for a different button.
ui.registerScript("ShowMoreInfo", function(warning)
  pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
      Title = tostring(warning.title or "ArcScriptCenter"),
      Text = "This is an informational warning from ArcScriptCenter.",
      Duration = 6
    })
  end)
end)

return true
