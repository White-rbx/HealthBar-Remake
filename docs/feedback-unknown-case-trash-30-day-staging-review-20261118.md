# ArcScriptCenter — Unknown Feedback Case Trash / 30 days

**Status:** STAGING review-only source and synthetic QA complete. **NOT deployed.** PR #16 remains Draft. Production unchanged.

## Owner requirements

**Move Unknown Case To Trash** is available only for Feedback whose claimed_user_id is missing, with an explicit Admin confirmation per case. Trash supports **Restore** prior to the deletion deadline. Permanent deletion is due after **30 full days counted from moving to Trash**, not from Feedback submission.

## Backend safety and behavior

- Server checks the existing Admin Key and allowed Origin, even when UI hiding is bypassed; POST has explicit confirmation and UUID validation.
- Only active Feedback with blank/null claimed_user_id can be moved. A claimed account is not identity verification.
- A D1 batch transaction inserts a row into asc_feedback_unknown_trash and changes asc_feedback_cases.removed from 0 to 1. Its purge timestamp is trashed_unix + **2592000** (30 days).
- An Admin GET route returns a paginated Trash list without Receipt, admin_note or private message history.
- Restore is allowed before the deadline: in one D1 transaction, the original case is made visible again and its Trash marker removed; existing history and case status survive.
- When a **STAGING Worker Cron is actually configured**, purgeExpiredUnknownTrash can run hourly, up to 50 due cases per batch, with a transactional removal of Feedback case, all three related Feedback history tables, and Trash record via foreign-key cascade.
- Purge requires an active Trash marker, a moved case remaining removed, Feedback type, missing UserId, and expired deadline. Other cases (including cases separately removed by receipt) cannot be purged by this job.
- At the deadline Restore is unavailable, but if Cron is delayed physical deletion can happen later. Hourly Cron normally clears a due record within about one hour after the 30-day deadline, subject to worker health and backlog. No Cron is installed in live STAGING today.
- Deletion concerns active D1 rows. Past backups and snapshots are not purged by this feature. Any separate copy has its own retention policy.
- **No existing Unknown Case has been moved automatically or modified during development.**

## Checked-in GitHub files

- migrations/feedback_unknown_case_trash_STAGING_REVIEW_ONLY_20261118.sql — additive D1 table and expiry index, **not applied to live STAGING**.
- sandbox/feedback-unknown-case-trash.mjs — Admin GET/POST route helper and strictly private scheduled purge helper; import by itself does not register either.
- sandbox/feedback-unknown-case-trash.test.mjs — SQLite-backed tests of authorization, confirmation, 30-day deadline, Restore, conditional hard deletion and related history cleanup.
- sandbox/feedback-admin-users-case-ui.mjs — optional injected callbacks loadTrash, moveUnknownCaseToTrash, restoreUnknownCase render the native Admin-only Move, Trash and Restore controls. Reuses existing Admin login; if callbacks are not wired, controls remain hidden.

A ChatGPT downloadable source kit also contains a native Pages Preview candidate based on older Stage16.49 reference source and local tests: **9/9 Backend and 13/13 UI/preview/Ban-policy = 22/22 PASS**. These tests are synthetic, not an Admin/browser acceptance test.

## Integration steps — remaining in Step 2/4

1. Validate the additive schema on an isolated D1 and separately approve STAGING migration.
2. Inject the server-side Admin auth and current Origin allowlist into createUnknownCaseTrashHandler; register only /api/v1/admin/feedback/unknown-trash under the existing Worker Admin router. No public purge URL.
3. After security QA, wire purgeExpiredUnknownTrash into the Worker scheduled handler; configure STAGING-only hourly schedule (example 0 * * * *); confirm routine deletion and error monitoring. Existing live STAGING Worker currently has no Cron.
4. Wire the new UI callbacks into the existing User's Case screen using its original faRequest Admin Key connection; retain original Dashboard, Ban and Warning functionality.
5. Deploy the **entire** native current Pages site to an isolated STAGING Preview before promoting it to the main STAGING URL. Current canonical Pages deployment is 3a36ea6d-d867-45a0-931d-87f6df64ed8c. The existing candidate references older Stage16.49 and **MUST NOT be deployed as a source-only ZIP**, because a prior such upload removed index.html and broke the site.
6. Test on phone/browser: explicit confirmation, eligible vs ineligible cases, list, Restore, deadline, logout data-clearing, denied Admin Key, CORS, and rollback. Only then enable the feature for real cases. Keep Production unchanged until a separate release approval.

**Progress:** Step 1 native Arcsen 7.3.51 UI accepted by owner; **Step 2 User's Case + Unknown Trash source/QA**; Step 3 Ban Selection vs Duration; Step 4 authenticated Violation + Production release.
