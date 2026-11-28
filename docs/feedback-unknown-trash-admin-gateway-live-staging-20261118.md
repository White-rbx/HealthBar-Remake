# ArcScriptCenter — STAGING Admin Trash Gateway activation (18 Nov 2026)

## Current state

**Step 2/4 — Admin Trash API deployed; native Dashboard controls are still NOT deployed.** Production unchanged.

### Backend actually deployed

- Worker: arcscriptcenter-trash-admin-staging
- HTTPS origin: https://arcscriptcenter-trash-admin-staging.kogpasan14.workers.dev
- GET/POST endpoint: /api/v1/admin/feedback/unknown-trash
- D1 binding DB: arcscriptcenter-staging, UUID cf322eed-f483-467b-9ec8-e973f9ea4fa5
- Service binding AUTH_API: existing arcscriptcenter-api-staging Worker (Admin identity verification)
- No Admin Key or other existing secret was copied, rotated, read or changed.

Security: every private GET/POST verifies X-Admin-Key through the existing Admin-only /api/v1/admin/feedback/summary response using the Service Binding. Missing/invalid key fails closed. Allowed Origins must exactly match the existing dashboard allowlist; preflight only permits GET/POST/OPTIONS and explicit headers. The only moving candidates are currently-active unlinked Feedback with blank/null claimed_user_id. Administrator must confirm moving or restoring using the exact expected phrase. There is no HTTP purge endpoint.

Permanent deletion remains on the SEPARATE Worker arcscriptcenter-trash-purge-staging with hourly Cron 0 * * * *, after 2,592,000 seconds from an explicit Admin move. At the full 30-day cutoff, Restore is denied; Cron typically purges at the next hour.

### Tested

1. QA gateway was deployed separately as arcscriptcenter-trash-admin-qa with QA D1 only. Its invalid-key live HTTP smoke caught Workers RequestInit cache-mode incompatibility (503 instead of 401), which was fixed without changing original STAGING API Worker. Rerun https://github.com/White-rbx/HealthBar-Remake/actions/runs/44310011970: SUCCESS.
2. The same tested code was uploaded to arcscriptcenter-trash-admin-staging and bound only to STAGING D1 and original Admin API Service Binding. HTTPS subdomain was enabled.
3. HTTPS smoke covering both QA and STAGING (missing key 401, incorrect synthetic key 401, unauthorized origin 403, preflight 204, unauthorized POST 401, no purge route 404): https://github.com/White-rbx/HealthBar-Remake/actions/runs/44310750689 — SUCCESS. No actual Admin Key was used.
4. The Dashboard callback adapter sandbox/feedback-unknown-trash-dashboard-bridge.mjs reuses the existing page's Admin Key kept in tab memory. It supplies loadTrash, moveUnknownCaseToTrash and restoreUnknownCase to sandbox/feedback-admin-users-case-ui.mjs, without a second login. Its lock-race, confirmation, fixed-url and unauthorized tests passed in https://github.com/White-rbx/HealthBar-Remake/actions/runs/44312175626.
5. Cloudflare D1 postcheck still: 7 current Feedback cases, 3 with no UserId, 0 removed cases, 0 Trash entries. Main API Worker remains version 666d7be4-78ea-43ee-9f63-92e5faac38b6 and canonical Pages is 3a36ea6d-d867-45a0-931d-87f6df64ed8c with Functions enabled.

### Remaining UI integration release gate

The live Pages canonical index.html hash is b388e6140f1ade679f99046116732ecb, whereas the available old Stage 16.49 review source index hash is 35c63af97a960d9d03647dd5bfd9e8bc. Never deploy the old review-only source ZIP as a complete Pages site (a previous attempt took the site offline).

Need the EXACT canonical native Pages HTML, logo and Functions source (or safe reconstruction). Integrate only the original Admin User's Case page, supplying createTrashDashboardCallbacks({getAdminKey:()=>faState.key}) after the existing successful Admin unlock. Keep existing routes, assets, original Admin Key and Ban/Warnings/Analytics pages. Show Move only on unlinked Feedback; show Trash and Restore only to authenticated Admin. Deploy to a noncanonical STAGING Preview, test with the owner's Admin session privately, then consider promoting the main STAGING Dashboard. Do not merge PR #16 or change Production as part of this step.

**Current step:** 2 of 4. Trash D1 table, Cron and Admin Gateway operational; native Dashboard buttons not live. Step 3 Ban Selection vs Duration and Step 4 authenticated Violation/Appeal remain later stages.
