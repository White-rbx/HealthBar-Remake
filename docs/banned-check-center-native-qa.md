# Banned Check Center native QA

Use PR [#16](https://github.com/White-rbx/HealthBar-Remake/pull/16) and the
[isolated STAGING dashboard](https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans).
The shared STAGING API currently runs the Feedback and Appeal release. The
isolated QA Worker serves the v2 Ban Center. Its Roblox policy route requires
the matching Worker secret and Roblox universe; when missing it denies the
request with `identity_unavailable`. Keep `UseStagingGitHub` off for this pass.

## Set up the owned test experience

1. In the dedicated QA Worker, provision `BAN_GAME_SERVER_SECRET` as a Worker
   secret and `BAN_GAME_UNIVERSE_ID` as the authorized test universe ID. Add
   the exact owner-approved test account IDs to `BAN_QA_ALLOWED_TEST_IDS`
   as a comma-separated list. Use the Universe ID, rather than the Place ID.
   Keep the existing QA D1 and rate limiter bindings. Use only test accounts
   and a test secret specific to this Worker.
2. Allow HTTP requests in the owned Roblox experience. Configure the matching
   `BAN_GAME_SERVER_SECRET` in Roblox's Secrets Store for the QA Worker
   hostname. Install
   [the bridge](../sandbox/ArcScriptCenterBanBridge.server.lua) as a Script
   in `ServerScriptService` and start a new server. The server constructs the
   subject from the invoking Player. Admin Unlock and `USERCASETOKEN` are
   separate credentials.
3. Use the existing supported ExperienceSettings QA client to run
   [BannedCenterLoaderPreview.lua](../sandbox/BannedCenterLoaderPreview.lua).
   Call this entrypoint with `"roblox_server"` to select bridge mode. The
   default [Universal QA](banned-check-center-universal-qa.md) uses public lookup.
   Record the tested Git SHA and use the same snapshot of the Preview scripts
   for the entire run. This entrypoint and existing Loader and Arcsen use
   `getgenv`, `game:HttpGet`, and CoreGui. For a normal Studio LocalScript,
   use the bridge-only smoke below. Test the full UI in the project's
   supported Preview runtime inside the owned test experience.
4. Start with a clear test account. In **Banned Check Center**, use the
   existing private Admin Unlock and **Load QA Bans**. Choose the test ID,
   selection and duration. For temporary cases, choose an end time a few
   minutes ahead in ICT. Use **QA** actions and record the start/end times
   and expected state. Leave any unrelated fixture rows alone.

## Bridge-only smoke with ordinary Roblox services

Copy [BanPolicyClientPreview.lua](../sandbox/BanPolicyClientPreview.lua) into a
ModuleScript named `BanPolicyClientQA` in `ReplicatedStorage`. Run the
following temporary LocalScript in `StarterPlayerScripts` in the owned test
experience. Check the Output after each Rejoin. This verifies the Roblox
server bridge only. The full Loader, HealthBar and Arcsen acceptance checks
are in the matrix below.

```lua
local module = game:GetService("ReplicatedStorage"):WaitForChild("BanPolicyClientQA", 10)
assert(module, "Missing BanPolicyClientQA")
local client = assert(require(module), "Roblox QA server bridge unavailable")
assert(client.isolatedQA, "Use the isolated QA Worker")
local policy = assert(client.policy(), "Restriction status unavailable")
assert(client.secondsRemaining(policy) > 0, "Policy already expired")
print("[ASC QA] Server-confirmed state:", policy.state)
```

## Native acceptance matrix

| Scenario | Expected on the Roblox client |
| --- | --- |
| Clear → temporary Ban in-game → Leave/Rejoin | SetUp shows Reason, Description, Temporary, ICT end time; no Loader main. Leave SetUp open through expiry. The next server-confirmed clear resumes SetUp. |
| Clear → permanent Ban in-game → Leave/Rejoin | SetUp shows Permanent; no Loader main. Remove by Confirm Remove, reload the QA list and wait for SetUp to resume on the next successful check. |
| Clear → temporary Restricted → Leave/Rejoin | SetUp finishes and main opens. Editor, Search and RecommendedScript cannot open. Denied TopBar buttons have `Interactable=false` and background RGB 89. Arcsen Chat/New Chat and Send cannot be used. Open/Close, About and Arcsen Settings work. Wait through expiry and confirm access restores in the same session. |
| Clear → permanent Restricted → Leave/Rejoin | Same restrictions. In another tab confirm removal and reload QA Bans. In Arcsen Settings use **Refresh Roblox Server Policy**. Verify the TopBar restores original properties and Chat, Editor, Search and RecommendedScript work again. Rejoin and confirm the bridge returns clear. |
| Rapid change after Get Load, concurrent admin edit | An old confirmation cannot overwrite a newer revision. During a long startup the Loader must recheck an expired policy before protected tools load. If the policy tightens after full Loader startup, it blocks the current UI and asks for Rejoin. |
| Missing bridge / unavailable Worker | Use an owned test copy with the bridge absent or HTTP unavailable. SetUp reports unavailable and cannot admit the player. If a server check stops responding mid-session, the old decision expires and the Loader hides until a fresh result. |
| Violation / approved Appeal | Using an existing **synthetic, server-linked** QA notice, verify Restricted can open Arcsen → Settings → ArcScriptCenter → Feedback & Appeal → Violation. Loaded Approved status is green with no repeat Appeal. An account with no linked history has no Violation tab. |
| Existing Feedback and HealthBar | Verify opted-in Remember, restart/rejoin and automatic restoration of authorized cases. Use **Refresh and Check Server's case** and verify an independent Feedback case without a ban token. Check original HealthBar behavior after normal startup and after restoring from Restricted Mode. |

Clear the QA test records via the same Confirm Remove sequence. Verify
both the fresh QA list and the bridge-only smoke return the expected state.
Remove the temporary LocalScript and QA ModuleScript if added. Keep the
bridge scoped to the authorized test universe. If the Candidate needs to be
rolled back, revert the native QA commit on a review branch and retest the
prior entrypoint. It changes no Cloudflare Worker, Pages assets, D1 schema
or managed GitHub Ban source. Verify the shared STAGING versions and D1
bindings before any separate rollout.

The server-authorized v2 endpoints enforce their own permissions. The GUI
locks are presentation. Existing direct-to-provider AI calls and
locally loaded tools do not become server-authorized by this Preview.
Production needs native acceptance in the owned universe and a decision
on which privileged operations must move behind a server policy gate.
