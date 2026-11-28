# ArcScriptCenter — STAGING Unknown Feedback Trash infrastructure activated (2026-11-18)

## Status

**STAGING D1 schema: INSTALLED. STAGING standalone scheduled GC: DEPLOYED + HOURLY CRON ENABLED. Admin Move/Restore HTTP API + Dashboard User's Case: NOT YET DEPLOYED. Production: UNCHANGED.**

This supersedes the "schema absent / no Cron" status in the earlier review-only document, without changing that document's design requirements.

## Verified direct Cloudflare operations

- Account: ArcScriptCenter account, STAGING D1 **arcscriptcenter-staging** (UUID `cf322eed-f483-467b-9ec8-e973f9ea4fa5`).
- Created and tested separate synthetic QA D1 **asc-unknown-trash-qa-20261118** (UUID `3bf5266f-8ee0-4cbd-bf3f-c2de4ea45bfa`). It has no actual user submissions. Using Cloudflare's D1 REST API, verified only unlinked Feedback is eligible for moving, Restore works, the timestamp boundary is 2,592,000 seconds, no deletion before deadline, expiration deletes case and associated synthetic history, and Foreign Key checks pass.
- Discovered a D1 runtime-specific bug: `D1Result.meta.changes` counts writes performed by SQL triggers and ON DELETE CASCADE. A single case UPDATE or DELETE can yield `meta.changes=2`. Updated the GitHub Trash module to check **one or more** changed rows rather than equality with 1; added a CI regression using simulated D1 metadata. Previous strict equality would misleadingly report 409 or a zero purge count despite a successful operation.
- Installed **`asc_feedback_unknown_trash`** table and **`idx_asc_feedback_unknown_trash_expiry`** index on **STAGING D1 only**. Verified pre/post case data identical: **7 total cases, 3 without UserId, 0 with removed flag, 0 Trash rows**; `PRAGMA foreign_key_check` returned no issues. No user records were moved, restored, or deleted.
- Created **new** independent Worker `arcscriptcenter-trash-purge-staging` with two ES modules and ONLY one D1 binding `DB` to STAGING D1; does **not** replace `arcscriptcenter-api-staging`. Cron-only entrypoint calls `purgeExpiredUnknownTrash`, and the fetch route returns HTTP 404. No Admin Key or private data embedded. Uploaded using Cloudflare's supported Workers multipart Script Upload API.
- Configured and independently read back its Cron **`0 * * * *`** (hourly at minute zero, UTC). Production and main STAGING API Worker do not gain new Cron schedules. A due row will normally be removed on the first scheduled run after its full 30-day deadline (subject to Cron delivery, errors, and backlog up to 50 per run).
- Audited after rollout: STAGING Pages canonical deployment still `3a36ea6d-d867-45a0-931d-87f6df64ed8c`, Pages Functions enabled; original STAGING API Worker version still `666d7be4-78ea-43ee-9f63-92e5faac38b6` at 100%.
- GitHub CI [44304393286](https://github.com/White-rbx/HealthBar-Remake/actions/runs/44304393286) passed the independent Cron safety test and existing release checks. The Cron Worker is not yet proven via an actual future Cloudflare Scheduled Event: schedule and binding verified, but no due user rows exist.

## Source files in this Draft PR

- `sandbox/feedback-unknown-case-trash.mjs`: Admin-only Trash handlers (NOT LIVE), and private 30-day scheduled purge helper (now used by dedicated Cron Worker).
- `sandbox/feedback-unknown-trash-cron-staging.mjs`: isolated scheduled Worker, never public deletion HTTP.
- `sandbox/feedback-unknown-trash-cron-staging.test.mjs`: Cron gate + HTTP 404 + DB binding guard.
- `sandbox/feedback-unknown-case-trash.test.mjs`: SQLite-backed Admin permissions and 30-day boundary regression including D1 trigger/cascade metadata.
- `migrations/feedback_unknown_case_trash_STAGING_REVIEW_ONLY_20261118.sql`: exact migration **already applied to STAGING D1 only**.
- `sandbox/feedback-admin-users-case-ui.mjs`: UI controls remain review-only until the actual native Dashboard source is patched and tested.

## Remaining work / guard rails

1. **Step 2/4 still OPEN.** Existing API Worker does not yet implement the authenticated `GET/POST /api/v1/admin/feedback/unknown-trash` route, and current Admin Dashboard does not show Move/Trash/Restore. The table and Cron alone cannot move cases.
2. Integrate Admin route with the **original existing Admin Key authentication** and exact Origin allowlist. Never authorize based on claimed UserId.
3. Integrate UI into the exact original Pages website with full `index.html`, logo, Pages Functions and routes. Do not deploy the review-only ZIP in place of the site (previous outage).
4. Verify unauthorized 401/403, 30-day Restore cutoff, user-facing Receipt 404 while trashed, real Admin navigation and case selection; use synthetic cases for destructive acceptance, not current 3 actual unlinked cases.
5. Continue Step 3 Ban Selection vs Duration; Step 4 authenticated Violation and Production release independently.

**Privacy:** the hourly purger logs aggregate counts, never UserId, contents or receipts. It deletes only explicitly trashed unlinked Feedback whose full 30-day deadline has passed. Older backups/snapshots are outside this purge's scope.
