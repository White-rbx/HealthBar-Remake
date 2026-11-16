# ArcScriptCenter — Production Release Readiness (2026-11-16)

**Decision: NO-GO for Production.** The Stage 16.75 Sandbox Automatic Android Push Retry is **complete**: 37/37 offline tests, live scheduled Cron retry, HTTP 201 push acceptance on the second attempt, Android notification confirmed by the owner, and synthetic-data cleanup. This report is a **read-only Production/Staging/Sandbox audit plus release design**; it is *not* authorization to deploy, run migrations, copy data or modify secrets.

Repository: `White-rbx/HealthBar-Remake`  
Preparation branch: `stage16-63-protected-http-test`  
Production Worker: `arcscriptcenter-api`; staging: `arcscriptcenter-api-staging`; isolated Sandbox: `arcscriptcenter-merge-sandbox-1658`.


## Additive Production-schema rehearsal — completed (2026-11-16)

**Outcome: PASS for schema compatibility, NOT Production deployment authorization.** All live source and D1 reads were read-only for the existing Production, Staging and established Sandbox.

### Additive Migration artifacts

The two source-controlled **draft** migration files now cover the **23** target application SQL objects:

- `migrations/2026-11-15_stage1669_feedback_appeal_additive.sql`: **18** SQL objects (6 tables, 8 indexes, 4 triggers).
- `migrations/2026-11-16_stage1675_push_cron_additive_DRAFT.sql`: **5** SQL objects (3 tables, 2 indexes) derived directly from live Sandbox `sqlite_master` definitions, with **no data, endpoints or secret values**.

Excluded explicitly: `asc_stage1672_test_control` and `asc_stage1673_real_push_control`. The new file is **review-only**; do not execute against Production or Staging without a separate explicit approval.

### Isolated Cloudflare D1 rehearsal

Created a **new disposable and unbound** D1 database, named `asc-stage1675-release23-rehearsal-20261116`; verified it was distinct from all three application D1 databases. Read only schema definitions of the **current live Production** and established **Sandbox** databases. Verified all 47 current Production explicit SQL definitions match the identically named Sandbox definitions after conservative whitespace/quote normalization. Sandbox contains 25 additional entries; excluded two test controls and retained exactly 23 application additions.

Applied exactly **68 CREATE statements** to the disposable D1 in type order: 31 tables, 33 indexes and 4 triggers. Two internal/system tables (`_cf_KV`, initially present, and SQLite's automatically created `sqlite_sequence`) were not manually recreated.

Independent post-rehearsal D1 queries confirmed:

| Check | Observed |
|---|---|
| Explicit SQLite schema definitions | **70/70 match** Production + 23 vetted additions |
| Missing / extra schema objects | **0 / 0** |
| D1 `PRAGMA quick_check` | **ok** |
| D1 `PRAGMA foreign_key_check` | **0** |
| Test-only Stage16.72/16.73 tables | **Excluded** |
| Production/Staging D1 writes | **None** |

A single synthetic Feedback row was inserted only in the disposable D1, which generated one `submitted` history event via the database trigger. A synthetic Outbox item was advanced using SQL through **retry → sending → delivered**, with attempt count 2, verifying its constraints and lease/state transition. The `201` stored in this fixture was **simulated SQL data, not a real Web Push HTTP response**. No actual device Push was attempted in this rehearsal.

The isolated database was then **successfully deleted** after verifying that it was not bound to any Worker and contained only the synthetic fixture. No residual rehearsal DB or fixture remains.

**Note:** The first preflight attempt was stopped by an incorrectly escaped SQL-statement-checking regex before any DDL was executed. The guard was corrected, preflight rerun and the complete rehearsal passed. This was a local preflight issue, not a Production or D1 migration failure.

### Pinned Worker source merge manifest

The GitHub test branch now includes `sandbox/production-candidate-merge-manifest.json` containing **only** SHA-256 source fingerprints, allowlisted code-section boundaries, safety exclusions and missing release gates:

- Production base: `0.5.41.5-phase1` (71,521 UTF-16 code units).
- Sandbox feature reference: `0.5.79.0-cron-retry-sandbox` (201,179 UTF-16 code units).
- Selected code families: Feedback/Appeal, genuine Siteverify, Admin Notifications/Web Push, Durable Outbox, automatic Cron.
- Excluded: Stage16.64/16.66/16.67/16.72/16.73 testing pages and routes; test-only D1 tables.
- **No Production Worker source snapshot, private Push endpoint, Admin credential, secret binding value or user record was committed.**

The manifest and source boundary selection have now been supplemented by a **local-only, review-only assembler**: `sandbox/production-candidate-assembler.mjs`. It requires the exact private Production/Sandbox source snapshots and rejects any hash mismatch before creating output. It selects only reviewed feature-family sections, replaces Sandbox-specific real/dummy verification paths with production-oriented fail-closed guards, preserves the legacy Production route body, strips test-only routes and runs a local Node syntax check on its generated candidate. It has **no Cloudflare API invocation and never deploys**. It does not publish Worker source or secret values to GitHub.

**Actual GitHub-hosted offline review result:** <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43862268650> — **SUCCESS**. The Workflow verified the assembler's Node syntax, validated the review-only manifest and confirmed that input files with incorrect SHA-256 values are **rejected before output**. The first Workflow run had a typo in the pinned checkout SHA and failed at setup; the SHA was corrected to the working pinned checkout version used by the project's previous CI.

**Important distinction:** The assembler has **not yet been executed end-to-end with both private Worker source snapshots**. Neither a complete, assembled Candidate artifact nor a live preproduction acceptance test is certified by this report. The selected code is still a review draft; the production-specific Access hostname, real Turnstile widget/configuration, VAPID/admin credentials, backup/recovery and final source review are all separate release gates.

**Updated decision:** Isolated 23-object D1 schema rehearsal PASS; review-only source integration tooling and offline negative-input review PASS. Production Candidate **NOT RELEASE READY**, **Production NO-GO**.

**Updated Gate:** Additive SQL compatibility on isolated D1 **PASS**. Source merge, true Production configuration, independently verified Production backup/restore, code review, preproduction acceptance and Production authorization **PENDING — NO-GO**.


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
