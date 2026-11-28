# ArcScriptCenter — Production-first Code Review (No Backup Retrying)

**Reviewed:** 2026-11-17  
**Branch:** `feedback-appeal-release-track` · **PR #16 remains Draft**  
**Environment:** Cloudflare production and STAGING Workers + D1 schemas, **READ ONLY**; GitHub migration/merge manifest.  
**Decision:** **DO NOT DEPLOY** the STAGING Worker wholesale or run the existing migration blindly. This code review does not change or replace data-recovery requirements.

## Evidence examined

| Surface | Actual inspected state |
|---|---|
| Live Production Worker `arcscriptcenter-api` | 71,521 JS characters / 1,231 lines; SHA-256 `036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48`; compatibility date `2026-11-04` |
| Live STAGING Worker `arcscriptcenter-api-staging` | 301,664 JS characters / 1,822 lines; SHA-256 `cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62`; compatibility date `2026-11-13` |
| Worker bindings | Both have five similarly named bindings: `ARCSCRIPT_ADMIN_KEY`, `ARCSCRIPT_POLICY_SIGNING_KEY`, `ASC_ANALYTICS_HASH_KEY`, `DB` and `GITHUB_TOKEN`. No secret **values** inspected or copied |
| Production D1 `arcscriptcenter-db` | 22 app tables, 23 explicit indexes, 0 custom triggers; **NO** `asc_feedback_cases` |
| STAGING D1 `arcscriptcenter-staging` | 17 app tables, 20 explicit indexes, 4 custom triggers; has Feedback & Appeal schema |
| GitHub `migrations/2026-11-15_stage1669_feedback_appeal_additive.sql` | Existing 6-table/8-index/4-trigger **DRAFT**, not yet validated for current Production |
| GitHub `sandbox/production-candidate-merge-manifest.json` | Explicitly forbids full STAGING Worker copy, sets `productionDeploymentPermitted:false` and requires separate release security checks |

No personal rows, Admin Key, OAuth tokens, receipts, or private case contents were read or committed in this audit.

## Findings (prioritized)

### BLOCKER A — Production does not implement Feedback endpoints

The live Production Worker does **not** expose `/api/v1/feedback/submit`, `/api/v1/feedback/status`, `/api/v1/feedback/manage` or `/api/v1/admin/feedback/*`. STAGING exposes these endpoints. The two Worker sources differ substantially; full-file replacement would put unrelated routes, staged controls and compatibility changes at risk.

**Fix:** review an **additive, minimal Worker source diff** that preserves ALL existing production routes and the existing D1 + secret bindings. Do not ship STAGING-only routes, test fixtures, or sandbox credentials. Protect all Admin feedback routes server-side.

### BLOCKER B — Production D1 does not have the schema

The live Production D1 lacks the Feedback tables and triggers. The live STAGING D1 has: `asc_feedback_cases`, `asc_feedback_history`, `asc_feedback_followup_history`, `asc_feedback_followup_details_history`, `asc_feedback_quota` and `asc_violation_notices`. STAGING also has Feedback indexes and four history triggers.

The GitHub DRAFT `stage1669_feedback_appeal_additive.sql` is **not a byte-for-byte copy of current STAGING**: it defines `asc_feedback_quota_v2` (not found in the inspected STAGING schema) and does NOT define `asc_violation_notices` (present in STAGING). Its 8 Feedback indexes do not cover the separate violation and global warning indexes. These may be intentional scope differences, but they MUST be reconciled; never run a migration just because the counts look plausible.

**Fix:** define the **smallest approved feature scope**, reconcile each exact CREATE statement and dependency against the live target schema, rehearse on a disposable DB, and review D1 migrations as a separate explicit change. Do not drop or overwrite any existing Production table.

### BLOCKER C — STAGING native Feedback limits everyone together

The inspected `fcSubmit` enforces global `12/min` and `200/day` limits in `asc_feedback_quota`. The handler's submit path has **no per-requester network-scoped bucket** and **no Turnstile/Siteverify check** inside the native `fcSubmit` path. This is an availability risk: one abusive sender could exhaust the shared allowance. STAGING tests that passed do not prove the endpoint is abuse-resistant at Production scale.

**Fix:** consider server-side global + independently attested per-requester rate limiting, fail-closed on missing trusted network evidence, and independently test the browser Turnstile and the native Arcsen flow. A client-supplied Roblox UserId is **NOT** a trustworthy rate-limit or identity key. Never make OAuth an arbitrary prerequisite for ordinary Feedback.

### PASS — Basic request and access boundaries are present

- The inspected `adminAuthenticated(request,env)` rejects an absent/short Admin secret and uses SHA-256 digests with byte-wise comparison for the `X-Admin-Key` supplied by a caller.
- `fcCheckReceipt` checks case ID and a 64-hex-character private Receipt, hashes it server-side and queries `id=? AND receipt_hash=? AND removed=0` using bound parameters.
- `fcStatus` returns a restricted public projection and receipt-scoped history, not `admin_note`, `receipt_hash` or `claimed_user_id`.
- `fcManage` limits edit/remove to `reviewing` with revision under 5, and puts those conditions in its SQL `UPDATE` clause to handle concurrent changes.
- `fcSubmit` requires validated text and treats an optional `claimedUserId` as an **unverified claim**, not authorization.
- `fcAdminFeedbackCase` requires Admin authentication and bound-case lookup.

**Limit:** source inspection and synthetic tests are evidence of intended behavior, not a formal penetration test or proof of every edge-case authorization.

### REVIEW — Release UX / compatibility

- STAGING Browser Preview and Admin UI support Feedback with an unverified UserId, verified by the owner. Production Dashboard does not automatically gain this feature by shipping HTML alone.
- Native Arcsen Feedback should remain usable without OAuth. A future browser-only Turnstile verification rule applied blindly to a native Luau caller would break the existing experience; define and test both transports separately.
- Review Dashboard CORS allowlisted origins, admin-secret lifecycle, message rendering as plain text, custom error paths, and mobile layout before release.
- Existing `sandbox/production-candidate-merge-manifest.json` includes extra Push/Outbox/Cron components that are **not inherently necessary** for this Feedback release. Avoid importing those features merely to ship Feedback.

## Minimal review and test plan — no more backup loops

1. **Code-focused diff:** start from exact live Production Worker (pinned SHA above), add only narrowly selected Feedback logic and preserve original exports, routes, compatibility date unless justified, and bindings. Require tests for unchanged legacy routes.
2. **Schema-focused diff:** settle which of Feedback + Violation tables/indexes/triggers are required; reconcile the draft migration with current STAGING source. Prefer additive DDL; no Production mutation in this review.
3. **Offline tests:** Admin 401 without Key; correct key behind private test; Receipt valid/invalid; unverified UserId cannot read another case; Spam Mail admin-only; edit/remove revision gates; CORS from intended Dashboard origin; native sender flow; quota exhaustion/recovery.
4. **Release gate:** manual approval for all Production changes. Data-recovery limitations remain documented elsewhere but should **not** repeatedly interrupt source review and STAGING feature work.

**Verdict:** Source inspection is the sensible NEXT STEP. The code has two concrete Production compatibility blockers (routes and schema) plus a rate-limit design concern. Do NOT call these resolved simply because STAGING worked, and do NOT auto-deploy.

**No Production or STAGING Worker, D1 or Pages mutation occurred during this audit.**
