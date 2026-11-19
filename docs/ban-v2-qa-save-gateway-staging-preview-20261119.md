# ArcScriptCenter — Ban Schema v2 + QA Save (19 November 2026)

Status: **QA infrastructure and native STAGING Preview deployed; actual GitHub Ban Save is NOT enabled.** Production untouched. PR #16 stays Draft.

## Source-of-truth safety

The actual loadstring/ExperienceSettings-SetUp.lua at last check still has a schema:1 managed Ban JSON block with 0 entries. The original Cloudflare STAGING API Worker validates schema:1 only. Writing schema:2 directly to the live GitHub file would break ban snapshot and UI-policy reads. Therefore this work never changes live managed bans.

The new sandbox/managed-ban-schema-v2.mjs:
- Strictly supports independent Ban Selection (ban_ingame / restricted_mode) and Duration (temporary / permanent).
- Requires Duration and expiresAt consistency; rejects unknown fields, invalid UserIds, duplicate IDs, bad ICT dates, and excessive entries.
- Migrates schema:1 to schema:2 without losing original fields. The old entries receive selection:unassigned, effective legacy behavior Ban in-game/SetUp-only; never silently reclassified.
- Uses the expected GitHub SHA to prevent stale writes and patches only the exact Lua managed block.
- Does not perform any network writes. Covered by sandbox/managed-ban-schema-v2.test.mjs.

## Cloudflare isolated QA Save

New Worker: arcscriptcenter-ban-v2-qa
Endpoint: https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/qa

- DB binding points ONLY to isolated QA D1 asc-unknown-trash-qa-20261118 (UUID 3bf5266f-8ee0-4cbd-bf3f-c2de4ea45bfa).
- Its own table asc_ban_v2_qa was initialized with schema2 empty entries and revision 0.
- Service binding AUTH_API checks the existing Admin Key using the original STAGING Admin Worker and its authenticated Feedback Summary route. No Admin secret or GitHub token was copied, rotated or read.
- GET returns a QA-only schema2 document and integer revision. POST accepts upsert/remove with expectedRevision. One conditional D1 UPDATE guarantees optimistic concurrency; a stale version returns HTTP 409.
- Exact approved browser Origins, no wildcard CORS, no storage of Admin keys, private no-store responses, unauthorized GET/POST denied.
- Never touches the real GitHub ban list, main D1 ban snapshot, or Roblox user permissions.

Tests: sandbox/ban-v2-qa-gateway.test.mjs and sandbox/ban-v2-qa-live-http-smoke.test.mjs, including simulated successful Admin writes for all four mode/duration combinations and real HTTP denial for invalid/no keys.

## Native Banned Check Center Preview

Preview: https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans

Cloudflare immutable deployment: 87875c66-4944-45f8-a192-39055cd84a36 (preview branch stage16-54-verified-unlock), uses_functions true. Assets are exactly the previous canonical index.html hash b388e6140f1ade679f99046116732ecb and acs-logo.png hash 4b25ba35fd0d822ee53b65413f589a48.

Changes to existing native Banned Check Center:
- Ban Selection and Ban Duration are separate dropdowns.
- Each existing managed ban is labeled with its known Selection + Duration; legacy entries say Selection not set (legacy: SetUp-only).
- Separate Save to QA Sandbox and Load QA Bans controls.
- Dedicated QA Sandbox — not active bans records panel; synthetic records cannot be mistaken for actual bans.
- Existing native Admin Unlock clears the input after using it. The addon now captures the SAME Admin Key into tab-local memory in its capture-phase Unlock listener, and clears it on Lock; it is never sent in URLs or persisted in storage.
- Original GitHub Save is intercepted and disabled so schema2 values cannot be silently discarded by the old schema1 write path.
- No duplicate Login page, no GitHub writes, no current ban modification.

Source: sandbox/ban-check-center-selection-preview.js and sandbox/pages-native-ban-center-mode-preview-20261119.js.
Tests: sandbox/ban-center-v2-qa-save-ui.test.mjs and sandbox/ban-v2-qa-preview-live-http.test.mjs.

GitHub Actions SUCCESS: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44429079550

## Remaining release gates

1. The owner should privately test Admin Unlock > Load QA Bans > Save to QA Sandbox > Reload on the above Preview, without sharing the Admin Key. Real authorized QA HTTP persistence is not asserted until this acceptance test.
2. Upgrade source-of-truth STAGING Worker for backward-compatible schema:1/2 reader, snapshot, signed UI policy, Admin Ban POST, and GitHub audit BEFORE allowing real schema2 commits.
3. Test the reviewed Roblox SetUp -> restricted Loader main -> Arcsen Settings path with a synthetic account; maintain separate Ban in-game SetUp-only behavior.
4. Independently enforce account-bound API restrictions on server. Client-side Luau signals and self-reported UserIds do not prove Roblox ownership.
5. Do not change canonical STAGING or Production until safe review and acceptance.

No actual managed ban was changed in this QA rollout.
