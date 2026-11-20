# ArcScriptCenter — Ban v1/v2 compatibility bridge (STAGING, 2026-11-19)

## Scope, safety and current release state

**STAGING QA compatibility endpoint and native read-only UI are LIVE; canonical STAGING Worker and Production remain UNCHANGED.**
The original GitHub Ban List is NOT migrated and actual Roblox bans are NOT edited. PR #16 is Draft.

This release track addresses the gap between the original GitHub-managed Ban data
schema 1 and the reviewed schema 2 with independent Ban Selection and Duration.

Ban Selection: ban_ingame or restricted_mode.
Ban Duration: temporary or permanent.
Legacy schema 1 records migrate in **read-only output** as selection=unassigned
and effective SetUp-only behavior. Never infer restricted_mode from an expiry.

## Live QA compatibility endpoint

Cloudflare Worker: arcscriptcenter-ban-v2-qa
GET https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/compatibility

- Uses the existing exact-Origin allowlist and original Admin Key, verified
  through AUTH_API Service Binding to arcscriptcenter-api-staging.
- Calls the original authenticated GET /api/v1/admin/bans through the same
  Service Binding to read the current GitHub-managed records.
- Parses source schema 1 or explicitly annotated source schema 2.
- Returns readOnly=true, qaOnly=true, sourceSchema, sourceSha,
  entriesRead, legacyUnassigned, and a validated converted schema 2 document.
- Accepts GET only; has no GitHub write, public mutation or database migration.
- Any malformed or mixed v1/v2 records fail closed.
- Existing QA POST /api/v1/admin/bans/v2/qa remains isolated to the QA D1
  table asc_ban_v2_qa. No new Admin key or GitHub token is stored.

New tests: sandbox/ban-v2-source-compat.test.mjs (positive mocked GET for v1
and v2, invalid data rejection, unauthorized requests and no DB changes).
Real HTTP tests added to sandbox/ban-v2-qa-live-http-smoke.test.mjs.

### Native Banned Check Center Preview

https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans

New button: **Preview Ban v1 → v2** in the existing Banned Check Center
QA panel alongside Save to QA Sandbox and Load QA Bans.

- Reuses the original Admin Unlock session key in tab memory.
- Shows original schema, preview schema, number of entries, legacy entries,
  and each UserId / known username / Selection / Duration.
- Read-only: never submits a GitHub Ban Save.
- Original Save to GitHub remains intercepted and disabled.
- QA Save still writes ONLY to the isolated QA D1 and requires the original
  Admin Key, explicit confirmation and a revision match.

Deployed Pages Preview ID: 1a395835-6d4d-4d9a-a559-a8fe36b8567f.
Cloudflare validated environment=preview, uses_functions=true, current
canonical /index.html and /acs-logo.png asset hashes unchanged.
Original canonical STAGING Pages: 3a36ea6d-d867-45a0-931d-87f6df64ed8c.
Original STAGING API Worker version: 666d7be4-78ea-43ee-9f63-92e5faac38b6.

## Original 305 KB Worker compatibility patch, review only

File: sandbox/ban-v2-main-worker-compat-patcher.mjs.
Tests: sandbox/ban-v2-main-worker-compat-patcher.test.mjs.

The patch has been applied IN MEMORY to the **exact current original Worker
source fetched read-only from Cloudflare** and all expected anchors matched.

- Original source: 305533 bytes; SHA-256:
  87954d815e5bb0d97537448cfe784fd71fcbdd5b19fc9043c5ed164aad9d1626
- Resulting review candidate: 306185 bytes; SHA-256:
  b959af65f6c8610b7d373072fc9bf5fd142e982cfe9237b0a6710ec0eada7e3b

The patch adds:
- Ban data source parsing of schema 1 and schema 2, including strict
  enum and Duration/expiry validation.
- Schema field in original Admin Ban GET response.
- D1 managed-ban snapshot validation/read/write supporting schema 1 or 2
  without changing D1 table structure.
- Explicit snapshot schema passed from Admin Ban GET and GitHub refresh.
- Preserves signed UI Policy schema 1, original Verify Policy handler,
  existing Admin authentication and exact approved Origins.
- **Preserves the original hard-disabled GitHub Admin Ban POST.**
  This is a compatibility read patch, not a production write release.

The complete original Worker source was deliberately not overwritten; a
partial or truncated Cloudflare source MUST NOT be uploaded. The exact
anchor-based patcher is version guarded and rejects mismatched source.
Offline tests verify the patched code is syntactically valid on a pinned
structural fixture and that v1/v2 entries and snapshots validate separately.

## Remaining release gates

1. **Owner-private Admin QA acceptance:** use the native Preview, unlock with
   the original Admin Key privately, click Preview Ban v1→v2, and optionally
   Save to QA Sandbox/Load QA Bans on synthetic UserIds. Never paste key in chat.
   Live positive authenticated HTTP results are NOT claimed from negative
   smoke tests.
2. **Review and deploy original Worker compatibility candidate only after
   full-source syntax/runtime QA** in an isolated environment that has
   correctly scoped D1 bindings and no production write capability.
3. Upgrade genuine Admin Ban POST with conditional GitHub SHA, schema 2
   validation, audit logging and safe rollback, only after the dual reader
   is deployed and validated. Do not replace the canonical source with schema 2
   before the old v1-only reader is retired.
4. Validate Roblox SetUp/Loader main/Restricted Arcsen with separate synthetic
   test accounts for both Ban modes and both Durations.
5. Signed UI Policy currently remains schema:1, with identityVerified=false.
   A self-reported Roblox UserId and client-side Lua flags cannot grant
   account-bound authorization. Build trusted server-side enforcement before
   enabling actual Restricted Mode moderation.

The STAGING QA Ban table remains separate from all live Ban records;
the original live GitHub managed file was not changed by this work.
