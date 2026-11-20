# BANNEDTOKEN STAGING

The default Loader uses the [universal HTTPS case session](banned-token-universal-qa.md).
The owned-experience bridge below remains a separate QA entrypoint.

The server generates `BANNTOKEN_XXXXXXXXXXXX-XXXXXXXXXXX#XXXXXX`.

- The first segment is a 12-character server HMAC of the Roblox UserId.
- The second is an 11-character server HMAC of the UserId and normalized username.
- The third is a six-character random HEX value. The UI sees only `••••XX`.
- D1 stores the token hash and two-character display suffix, keyed by the
  verified notice and stable subject. It stores neither the raw token nor the
  first two segments. A rename preserves the existing reference.
- The token and its reference grant no permissions. The public ban endpoint
  never returns a reference, case data or a case grant. A reference can appear
  in an in-game warning only if trusted moderation has linked the verified
  notice to the exact currently active restriction revision.
- The existing verified-history route creates a reference only for notices
  already bound to the authenticated subject. A claimed ID or username, a
  case receipt, a six-character HEX value and `USERCASETOKEN` grant no
  Violation access. Feedback keeps its existing independent case-token path.

## Scope and Mobile QA

The dedicated worker source is `sandbox/banned-token-qa-worker.mjs`.
Apply `migrations/banned_token_ISOLATED_QA_ONLY.sql` only to a separate
synthetic QA D1 after the verified history and Ban v2 migrations. Configure
independent Worker secrets `BAN_GAME_SERVER_SECRET` and
`BANNED_TOKEN_SECRET`, the owned QA universe `BAN_GAME_UNIVERSE_ID`,
test account allowlist, isolated `BAN_QA_DB` and `BAN_V2_RATE`.
Use existing verified ownership records for linked notices. Trusted
moderation can call the server-side `linkBannedReference` helper to bind a
notice to its exact saved ban revision.

For native QA, install `sandbox/ArcScriptCenterBanBridge.server.lua` in an
owner-controlled test place and enable its `BannedTokenQA` Script attribute.
Give only the Roblox server the matching bridge secret. The Roblox server
gets the authenticated caller from `OnServerInvoke` and supplies the
account identity and username. To test the bridge and trusted policy mask in the same isolated QA dataset,
run the preview with `"roblox_server"`. This optional mode asks the player
for no sign-in or Case ID during startup.

On Roblox Mobile, check that the linked owner sees the masked reference
and verified Violation automatically, while an unbound account sees no
Violation. Check Restricted Mode, fully banned SetUp and WarningUI, and
Clear. Open the existing Appeal form, submit the verified case and verify
that Approved removes the submit control. Check that an unavailable
private channel leaves a public restriction visible and private data
hidden. A full Ban-in-game remains on SetUp. The dedicated Worker allows
the verified owner to submit an eligible appeal, while SetUp keeps the
existing appeal instructions and does not open Arcsen.

For rollback, remove the optional bridge from the QA place or turn off
`BannedTokenQA`. The original ban policy and Feedback deployments do not
inherit the synthetic worker's database or secrets.
