# Universal Banned Check Center QA

Use the [Banned Check Center QA dashboard](https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans)
and the [QA entrypoint](../sandbox/BannedCenterLoaderPreview.lua) in the
existing supported ExperienceSettings runtime. It asks the ArcScriptCenter
QA Worker for UI restriction status using the local player's Roblox UserId. Opening the STAGING `LoaderMainPreview.lua`
directly also selects Universal QA. Arcsen receives the same decision and
reports an unavailable QA state if the policy is missing.
The default QA entrypoint works without installing anything in the Roblox
experience. It performs the check again on each launch, including after
Leave → Rejoin. There is no account verification prompt for this lookup.
Clear sessions keep the existing Get Load and Always Load preferences.
Restricted QA continues into main automatically after SetUp and HealthBar readiness.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/BannedCenterLoaderPreview.lua"))()
```

## Check on Roblox

1. Use the approved test account `9777206932` with the existing **Restricted
   Mode — Permanent** QA record. Launch the entrypoint above and confirm
   the existing Client WarningUI shows **Footsteps** and **Permanent**,
   SetUp finishes and Loader main opens. Check that Editor, Search,
   RecommendedScript, Arcsen Chat and New Chat are inactive. Check that
   Open/Close, About, Arcsen Settings and authorized Feedback cases still work.
2. Leave and launch the same entrypoint in a second compatible experience.
   Confirm the same restriction without any extra setup in that experience.
3. With the normal approved Admin QA workflow, change a test record to
   **Ban in-game**. On a fresh launch or Rejoin, confirm the Client WarningUI
   appears over SetUp and SetUp stops before Loader main. Repeat both
   selections with a temporary QA record and confirm the server end time in
   ICT. Dismiss the popup and wait through repeated polls to check that the
   same warning does not return. Then remove the test restriction. From
   Restricted Mode, use **Refresh restriction status** in Arcsen or allow
   the automatic check to run. The UI restores tools after a fresh clear
   response. An existing session where the policy tightens may require a
   fresh Rejoin to reconstruct the correct UI.
4. Confirm the normal HealthBar, Feedback & Appeal and existing
   Remember Token flow. The public status lookup cannot fetch a private
   Violation notice. Account-verified notices and appeals still require a
   trusted path. The [bridge runbook](banned-check-center-native-qa.md) covers
   the optional server-authenticated QA mode.

When the QA Worker is unavailable, the Preview pauses rather than assuming
clear. The refresh window is at most 30 seconds and can shorten near
expiry. A restriction notice contains its duration, temporary end time,
and an explicitly allowlisted QA display reason, or a generic message
pointing to the verified case. The notice can carry an opaque revision
for deduplication. Private reasons, descriptions, start times, case IDs,
tokens and credentials stay outside this response. The QA Worker accepts only fixture IDs
and explicitly approved QA accounts. Outside-scope accounts receive an
explicit error with no policy state.

## Scope and rollback

The isolated `arcscriptcenter-ban-policy-qa` Worker reads the existing Ban
Center QA D1 snapshot and applies its own rate limiter. It exposes only
`POST /api/v1/client/bans/v2/status`. It has no route or binding for Admin,
case management, Appeals, account verification, or production databases.
The UserId is a claim. These three UI states do not grant API access or
control what an independently modified client can run. Existing protected
APIs continue to apply their own authorization.

The prior verified bridge remains available by passing `"roblox_server"` to
the same QA entrypoint. Revert the Universal Candidate commit on a review
branch to restore its old default. The standalone Worker can be removed
independently after reverting the client default. Keep the existing QA D1
and original Dashboard/Worker bindings.
