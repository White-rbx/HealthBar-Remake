# ArcScriptCenter — Production Release Readiness (2026-11-16)

**Decision: NO-GO for Production.** The Stage 16.75 Sandbox Automatic Android Push Retry is **complete**: 37/37 offline tests, live scheduled Cron retry, HTTP 201 push acceptance on the second attempt, Android notification confirmed by the owner, and synthetic-data cleanup. This report is a **read-only Production/Staging/Sandbox audit plus release design**; it is *not* authorization to deploy, run migrations, copy data or modify secrets.

Repository: `White-rbx/HealthBar-Remake`  
Preparation branch: `stage16-63-protected-http-test`  
Production Worker: `arcscriptcenter-api`; staging: `arcscriptcenter-api-staging`; isolated Sandbox: `arcscriptcenter-merge-sandbox-1658`.

## 1. Evidence from live read-only Cloudflare audit

| Environment | Active Worker version | Explicit SQL objects (tables + indexes + triggers) | D1 identity |
|---|---|---:|---|
| Production | `298de84d-418c-489c-b133-c549c785f66e` (`0.5.41.5-phase1`) | **47** | `arcscriptcenter-db` |
| Staging | `5b5040fb-6c04-4029-9c53-af15d3dda888` (`0.5.67.1-cors-response-staging`) | **43** | `arcscriptcenter-staging` |
| Sandbox | `1c6ce118-27b7-40c4-9c0d-2b8c6d3a4776` (`0.5.79.0-cron-retry-sandbox`) | **72** | `asc-stage1658-prodlike-20261115` |

Object counts include explicit `sqlite_master.sql` entries; counts are schema metadata, **not rows or application data**. All **47** explicitly defined Production SQL objects are present in Sandbox with the same whitespace/quote-normalized definitions. Sandbox has **25** additional objects, of which **2** are synthetic test-only tables; the release must not apply them to Production.

The 23 candidate *application* additions are:
- **18 Feedback & Appeal objects** already drafted in `migrations/2026-11-15_stage1669_feedback_appeal_additive.sql`: six tables, eight indexes and four triggers.
- **5 Push/Cron objects**: `asc_admin_push_subscriptions_v1`, `asc_push_delivery_outbox_v1`, `asc_push_cron_health_v1`, `idx_asc_push_outbox_due_v1`, `idx_asc_push_outbox_case_v1`.
- **Do not migrate** `asc_stage1672_test_control` or `asc_stage1673_real_push_control`. Do not copy Sandbox subscriptions, synthetic cases, Access identity, Endpoints, secrets or test-mode flags.

Staging is **not a production-schema substitute**: compared to Sandbox, three SQL objects exist only in Staging; eight shared table definitions differ under whitespace/quote normalization. A simple Worker promotion or migration transplant would be unsafe.

### Bindings and source compatibility

| Environment | Binding count | Key observation |
|---|---:|---|
| Production | **5** | Existing `GITHUB_TOKEN` secret and old admin functionality; **no** Turnstile, VAPID, Push Access or Feedback quota bindings |
| Staging | **5** | Existing `GITHUB_TOKEN`, Feedback routes in source; **no** Push, Cron or real Turnstile binding |
| Sandbox | **12** | Push, real Turnstile test integration, Sandbox Access and isolated D1; **no** `GITHUB_TOKEN` binding |

The current Production Worker does not contain the Feedback submit API, Siteverify or Push/Cron. The current Sandbox Worker **does** contain these but includes `VERSION.includes('-sandbox')`, `ASC_TURNSTILE_MODE==='sandbox-dummy'`, exact `ASC_STAGE1671_HOST` hostname enforcement and test-only routes/tables. These are appropriate for isolated testing, but must **not** be disabled or blindly replaced in Production without equivalent production-appropriate authorization and environment restrictions. Copying the Sandbox Worker wholesale would also risk regressing Production's existing GitHub management functionality and route behaviors. **Retain the original Production code, binding roles and deployed version as a rollback baseline.**

### Backup evidence

A read-only D1 Time Travel bookmark is currently available for each of Production, Staging and Sandbox. **Bookmark availability is not an independently verified Production backup, export, clone or restore certification**. Stage16.66 previously passed a Time Travel rollback drill in a *disposable*, empty-of-user-data D1 only.

## 2. Blocking release gates (none should be silently waived)

1. **Code merge and environment isolation:** Produce a source-controlled Production candidate derived from the actual Production baseline; port vetted Feedback/Appeal, Push Outbox and Cron behavior without dropping old features. Implement a production-specific, fail-closed authorization and hostname policy, and remove test-only endpoints and synthetic controls. No hard-coded Sandbox Access aud, hostname, `sandbox-dummy` Turnstile mode or real user/test key mixing.
2. **Schema compatibility:** Review and rehearse the **23-object additive migration** against the exact current Production schema **in a separate disposable D1** with synthetic records. Match schema definitions and validate app behavior. The existing Stage16.69 18-object rehearsal alone does not cover Stage16.74/16.75 Push/Cron additions. No destructive ALTER/DROP or wholesale staging-to-Production data transplant.
3. **Production secrets:** Owner-controlled dedicated real Turnstile sitekey and server-side secret, server-side verification of hostname/action; separate production VAPID credentials, configured Access authorization, Feedback quota binding and Push security bindings. Store secret values only in Cloudflare secret management; never in GitHub, chat, test logs or browser code. Check production domain and authorized admin identities privately. Real Turnstile widget provisioning and final Access policy verification **not certified by this review**.
4. **Recovery:** Independent, verified export/restore procedure and designated rollback operator; snapshot/checkpoint before any migration. Worker version rollback alone does not revert D1 writes. Time Travel rollback may discard later writes and needs an explicit outage/recovery decision.
5. **Staged rollout:** First rehearse an isolated candidate, then explicitly approve any intended Staging changes and verify them without Production user data. Obtain **separate authorization** before any Production D1 migration, binding/secret changes, Worker deploy or Cron activation. Use bounded canary traffic and observe logs/health before 100%.
6. **Security and device acceptance:** Verify anonymous and disallowed-account denial, real Turnstile valid/invalid/replay/outage outcomes, Feedback/Appeal lifecycle, retention/privacy, one controlled Production-device subscription and Push receipt. A Sandbox subscription does not migrate to a different origin. Enable Production Cron only *after* its Worker `scheduled()` handler, bindings and D1 schema are validated.

## 3. Proposed release sequence — *plan, not execution*

1. **Freeze this acceptance baseline:** Sandbox 16.75, GitHub 37/37, Android receipt, D1 cleanup, existing Production and Staging version IDs.
2. **Produce one minimal release candidate** merging the Production baseline with only the approved Feedback + Push features. Review its diff; keep legacy behavior. No new arbitrary staging features, synthetic endpoints or chat-table changes.
3. **Package the reviewed 23-object additive D1 migration**, excluding two testing tables, and run it only in an isolated, disposable database in a deliberate rehearsal. Verify read-only schema diff, constraints and recovery.
4. **Provision and verify production-appropriate domain, Turnstile, Access and Push configuration under owner control** without revealing secret values.
5. **Test in a separately approved pre-production environment** with no Production data. Record GO/NO-GO evidence and rollback steps.
6. **Request an explicit Production Release authorization.** Without it, stop here. If approved later: back up, apply reviewed schema, deploy code in stages, verify 0 unexpected failures, enable Cron only after scheduled handler present, verify real Android receipt, preserve rollback version.

## 4. Stop conditions and acceptance

**NO-GO immediately** if the candidate removes an existing Production route, breaks GitHub integration, changes unrelated database tables, mixes Sandbox credentials with Production, lacks a protected admin identity, omits verified backup/restore capability, or has ambiguous rollback ownership.

**GO only after** schema/secret/authorization/recovery checks pass and the owner expressly authorizes Production changes. Current status: **NO-GO**, no Production or Staging mutations performed in this audit.

## 5. Immediate next engineering task

Build and review a **source-controlled Production candidate from the Production baseline**, not from a blind Sandbox copy. Its primary goal is to keep all 47 Production schema objects and existing features intact while adding **only** the vetted Feedback/Appeal + Push/Cron functionality. A separate, reviewed migration and configuration checklist must precede deployment.
