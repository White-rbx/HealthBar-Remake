# ArcScriptCenter — User's Case STAGING integration candidate (2026-11-18)

**Status:** Prepared, synthetic QA **9/9 PASS**, NOT DEPLOYED. Production and STAGING canonical unchanged.

## Actual milestone: 2 of 4
1. **Arcsen UI 7.3.51** auto-adds LocalPlayer UserId to new Feedback with visible disclosure. Owner confirmed the old opt-in button is gone. Actual network submit must still be verified on Roblox.
2. **Native Admin Dashboard User's Case**: created an in-place **review-only** Pages Worker candidate using the original Stage16.49 _worker.js retrieved from the owner's Library. The candidate reuses the **existing** Feedback & Appeal navigation, Admin Key, Admin GET /api/v1/admin/feedback/list (all five statuses, paginated), Admin GET /api/v1/admin/bans for any previously known Username, and the existing Admin Case Review selection handler. Groups cases by claimed UserId or Unknown / Unlinked. Blank search shows all loaded groups, username search works for names already stored in Ban List. Did not add new authentication, storage or ban decisions. The Feedback sidebar/header is renamed Feedback & Appeal (Beta Feature).
3. **Ban policy contract**: checked in `sandbox/arcscriptcenter-ban-selection-duration.mjs` plus synthetic test. Ban Selection (`ban_ingame` / `restricted_mode`) and Duration (`temporary` / `permanent`) are **independent axes**, allowing all four combinations. Existing legacy GitHub ban entries don't store selection; do not guess it or migrate without a reviewed schema and existing behavior check.
4. **Ban/Violation linkage + release**: server-authenticated user identity and real browser/Roblox integration still required; no Production release approval.

## QA and limitations
- Local tests `node --test preview_source.test.mjs ban_selection_duration.test.mjs`: 9/9 passed.
- Node syntax checks for embedded Worker and JS passed; simulated Worker JS/CSS responses were HTTP 200 and proper MIME, preserved original Admin anchors and safe HTML rewriting.
- Generated locally **review-only** zip `ArcScriptCenter_STAGING_UsersCase_Integration_Review.zip` in conversation (review source, build script, tests, patch, independent policy helper).
- **Critical:** This candidate uses **Stage16.49 Library `_worker.js`**, NOT the exact current canonical Pages Functions build from Nov 17. STAGING Pages canonical is `3a36ea6d-d867-45a0-931d-87f6df64ed8c`. It is unsafe to deploy the review-only ZIP as a whole Pages website. The previous outage was caused by promoting a source-only ZIP without `index.html` and Functions. DO NOT repeat.
- Browser Roblox Username/Display Name enrichment is a separate candidate in this PR; the new native preview bridge currently only displays known Ban List Usernames (if any), otherwise UserId. Do not claim the new public Roblox profile resolver is live.
- The current Worker already exposes authenticated `/api/v1/admin/feedback/list` with `claimed_user_id`, so the native bridge can use that route without a new backend endpoint. Existing advanced grouping endpoint `/api/v1/admin/feedback/users` remains candidate only.
- No live Browser, Cloudflare Preview, or actual Login session E2E tests yet.

**Next:** Acquire/rebuild the exact current STAGING Pages `index.html`, logo and Pages Functions bundle, merge the reviewed native bridge without duplicate login/nav, verify all original routes/assets and preflight, then publish to a separate STAGING Preview and test owner clicking real cases. Only afterwards consider canonical staging promotion. Do not touch Production.
