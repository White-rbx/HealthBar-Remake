# ArcScriptCenter — Production Release Readiness (2026-11-16)

**Decision: NO-GO for Production.** The Stage 16.75 Sandbox Automatic Android Push Retry is **complete**: 37/37 offline tests, live scheduled Cron retry, HTTP 201 push acceptance on the second attempt, Android notification confirmed by the owner, and synthetic-data cleanup. This report is a **read-only Production/Staging/Sandbox audit plus release design**; it is *not* authorization to deploy, run migrations, copy data or modify secrets.

Repository: `White-rbx/HealthBar-Remake`  
Preparation branch: `stage16-63-protected-http-test`  
Production Worker: `arcscriptcenter-api`; staging: `arcscriptcenter-api-staging`; isolated Sandbox: `arcscriptcenter-merge-sandbox-1658`.



## Production Cron telemetry bootstrap — resolved in review-only Candidate (2026-11-16)

**Security/reliability finding:** The first Production migration draft copied Sandbox's SQL constraint `CHECK(scope='sandbox_push_cron')` and had **no bootstrap row** in `asc_push_cron_health_v1`. The Cron handler uses `UPDATE ... WHERE scope=...` and the health UI uses `SELECT ... WHERE scope=...`. With an empty table, an otherwise successful scheduled invocation would silently leave `Runs=0` and `Last result=never`. Copying Sandbox's scope into Production would also mix environment-specific operational records.

**Fix committed only to the GitHub test branch:**

- Production D1 schema now uses `CHECK(scope='production_push_cron')`.
- Migration adds exactly **one non-user, idempotent operational bootstrap statement**: `INSERT OR IGNORE INTO asc_push_cron_health_v1(scope) VALUES('production_push_cron')`.
- Review-only Worker assembler checks that the 4 expected Sandbox Cron scope references exist, then rewrites all 4 to `production_push_cron` before creating the Candidate. It fails closed if the upstream source changes.
- No user Feedback record, Push endpoint, subscription, Secret or real Production telemetry is copied.
- 7 Python SQLite tests were added, together with 6 existing Node route-contract tests: **13/13 PASS in actual GitHub Actions run** <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43871855040>.
- Production scope was also tested in a **new disposable Cloudflare D1** with official D1 APIs: 3 tables and 2 indexes created, exactly one initial `production_push_cron` row, `runs` successfully incremented to 1, repeat `INSERT OR IGNORE` preserved the counter, `PRAGMA quick_check=ok`, 0 foreign-key violations. The disposable D1 was **deleted successfully**. No existing Production, Staging or Sandbox D1 was modified.
- Reassembled Candidate against the exact active, hash-pinned private Production and Sandbox Worker sources, in memory. V8 syntax PASS; all 4 Cron SQL references now use `production_push_cron` and 0 retain `sandbox_push_cron`. The original Production route body, Service Worker scope correction and Real Turnstile guard remain preserved.
- **Latest review Candidate SHA-256:** `9da9cf8a19995d3058d8f292424c49074377b3e5a7fe4727c31b65fce73e4841`; **151,554 UTF-8 bytes**, **149,956 UTF-16 code units**. No complete Candidate source was committed publicly or uploaded to Production.

**Correction to historical rehearsal evidence below:** The former 70/70 comparison proved the **earlier copied Sandbox-shaped** migration. The updated Production-only scope constraint intentionally differs from Sandbox, so that previous 70/70 comparison is **not** a fresh equivalence certification for the adapted DDL. The separate official Cloudflare D1 production-scope rehearsal above validates the new 5-object-and-bootstrap portion. The previously rehearsed 18 Feedback/Appeal objects are unchanged.

**Release decision:** This blocker is resolved in the **review-only Candidate**. Live Production HTTP testing, production-owned Turnstile/Access/Push credentials, full recovery certification and explicit Production deployment approval remain **PENDING / NO-GO**.


## Additive Production-schema rehearsal — completed (2026-11-16)

**Outcome: PASS for schema compatibility, NOT Production deployment authorization.** All live source and D1 reads were read-only for the existing Production, Staging and established Sandbox.

### Additive Migration artifacts

The two source-controlled **draft** migration files now cover the **23** target application SQL objects:

- `migrations/2026-11-15_stage1669_feedback_appeal_additive.sql`: **18** SQL objects (6 tables, 8 indexes, 4 triggers).
- `migrations/2026-11-16_stage1675_push_cron_additive_DRAFT.sql`: **5** SQL objects (3 tables, 2 indexes), with a **production-specific Cron health CHECK** and exactly one non-user bootstrap row; no subscription data, Push endpoints or secret values.

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

**Updated distinction (see first real-source assembly above):** The assembler was subsequently executed against both exact live Worker snapshots **in memory**, and its assembled candidate passed V8 parse-only verification and safety-string checks. It is not a persisted/release-ready artifact and has not passed Cloudflare Worker runtime tests. The production-specific Access hostname, real Turnstile widget/configuration, VAPID/admin credentials, backup/recovery and final source review are still separate release gates.

**Updated decision:** Isolated 23-object D1 schema rehearsal PASS; review-only source integration tooling and offline negative-input review PASS. Production Candidate **NOT RELEASE READY**, **Production NO-GO**.

**Updated Gate:** Additive SQL compatibility on isolated D1 **PASS**. Source merge, true Production configuration, independently verified Production backup/restore, code review, preproduction acceptance and Production authorization **PENDING — NO-GO**.



## First real-source Production candidate assembly — review-only PASS (2026-11-16)

**Scope:** Authorized read-only Cloudflare Worker source retrieval and GitHub test-branch assembler/manifest updates; **no Worker version upload, deployment, D1 write, Secret change or source publication.** Source bytes were processed in memory and were **not committed** to the public GitHub repository.

The exact active Worker sources were independently SHA-256 verified:

| Source | Version | SHA-256 |
|---|---|---|
| Production baseline | `0.5.41.5-phase1` | `036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48` |
| Sandbox feature source | `0.5.79.0-cron-retry-sandbox` | `dc4dedc563bd956ff9b24671f10c168d30728db4fe10e90954a1ad22db2bd24e` |

The pinned `sandbox/production-candidate-assembler.mjs` was executed against those exact inputs in an isolated JavaScript test harness, with private read/write file operations replaced by in-memory shims. The generated candidate was inspected **without uploading it**. Its source body was syntax-checked by V8 after replacing its sole module `export default` with a non-executed `const` declaration **for parse-only validation**; this is **not** a full Node or Cloudflare Worker runtime integration test.

**Verified assembly result:**
- **Candidate SHA-256:** `b76138e01e7384d9ba6bd2efe56682af9f323d13a6c128ff51db9232bac4ed9f`
- **UTF-8 bytes:** 151,540; UTF-16 code units: 149,942.
- **V8 JavaScript syntax:** PASS, one Worker default export.
- **Original Production legacy route body:** retained byte-for-byte in generated candidate.
- **Real Feedback & Appeal Siteverify:** required; previous dummy verification helper removed.
- **Host restriction:** new Feedback/Push routes fail closed when `url.hostname!==env.ASC_RELEASE_HOSTNAME`.
- **Admin Push Access:** identity verification remains required.
- **Disallowed test code:** no dummy token, Sandbox hostname, or Stage16.72/16.73 routes in generated candidate.
- **No executable candidate file persisted to GitHub or uploaded to Cloudflare;** this was private in-memory source review only.

The first real-source pass stopped at a misaligned check for `env.ASC_RELEASE_CHANNEL` versus the safe optional-chain `env?.ASC_RELEASE_CHANNEL`; the assembler invariant was corrected and real-source assembly then passed. An additional hostname guard was added after review, and the source was **reassembled and re-verified** to produce the final hash above. The latest CI run <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43864440030> passed assembler syntax, manifest checks, fail-closed wrong-input rejection and the source guard static checks. **CI does not itself fetch the live private Cloudflare Worker sources or execute a Cloudflare runtime test.**

**Decision:** The real-source **review candidate assembly** gate is PASS. However `releaseGates.candidateSourceCodeBuiltAndReviewed` remains **false** because runtime behavior, full diff/security inspection, authorized production-specific secrets and independent recovery certification are still pending. **Production remains NO-GO.** The next step is a private candidate runtime validation behind an isolated preproduction boundary, not a Production deployment.



## Isolated Cloudflare Worker Preview — compilation PASS; HTTP check blocked (2026-11-16)

**Purpose:** Verify that the exact hash-pinned Production Candidate can be compiled by the Cloudflare Worker Preview service, without deploying to the live Production or Staging Worker and without providing D1, Secret, Access or Cron bindings.

- Created **one disposable new Cloudflare Worker resource**, separate from the Production, Staging and established Sandbox Worker.
- Its normal `workers.dev` subdomain was **disabled**; the Worker had **no regular deployment**.
- Created an isolated **Preview** on that Worker with no D1, no Secrets, no Cron and no inherited bindings.
- Uploaded the exact approved Candidate SHA-256 `b76138e01e7384d9ba6bd2efe56682af9f323d13a6c128ff51db9232bac4ed9f` (**151,540 UTF-8 bytes**, compatibility date `2026-11-04`) directly to a **Preview Deployment**, not a Production or Staging deployment.
- **Cloudflare Preview Deployment API accepted the Worker code:** deployment ID `1dab78bd-e529-4cdd-ad46-5418bb38a519`, no bindings. This verifies **Cloudflare-side Preview upload/compilation**; it does **not** verify feature-level runtime responses.
- Attempted six HTTP requests to the isolated Preview. **All were blocked by the tool's network egress layer** with `403 Forbidden: requests to ... are not allowed` before reaching the Worker. These `403` responses are **not Cloudflare Worker authorization results** and must **not** be counted as passing or failing HTTP smoke tests. **No alternate network path or workaround was attempted.**
- After checking the isolated Worker's preview and zero live regular deployments, deleted the entire disposable Worker and Preview. The resource no longer appears in the Worker list. There is **no remaining public test URL or leaked preview binding**.

### Independent offline V8 request-handler tests — 11/11 PASS

Using the same two exact live Cloudflare source versions and the pinned GitHub assembler, assembled the Candidate **in memory** and instantiated its default Worker export under a minimal JavaScript V8 harness with synthetic Request/Response/Headers/URL stand-ins. This is an **offline code-path test**, not the full Cloudflare runtime. No real user data, D1 access, secret or network requests were involved.

| Test | Expected / observed | Result |
|---|---|---|
| Legacy bootstrap | `200` | PASS |
| Legacy chat-safety read-only status | `200` | PASS |
| Retired OpenChat endpoint | `410` | PASS |
| Feedback submission, DB missing | `503` | PASS |
| Feedback submission, release configuration missing | `503` | PASS |
| Admin Push health, release configuration missing | `503` | PASS |
| Cron status API, release configuration missing | `503` | PASS |
| Feedback submitted against wrong hostname with synthetic configuration | `404` | PASS |
| Admin Push against wrong hostname with synthetic configuration | `404` | PASS |
| Admin Push without Cloudflare Access identity | `401` | PASS |
| Cron scheduled handler without production settings | No error, no work performed | PASS |

**Result: 11/11 PASS (offline V8 harness), plus Cloudflare Preview compilation PASS, but Live Preview HTTP Smoke: BLOCKED / NOT VERIFIED.**

The GitHub `sandbox/production-candidate-merge-manifest.json` records the proof, explicitly distinguishes these layers and retains all Production NO-GO flags. The Preview was never linked to the real Production database or secrets. The deployed Production, Staging and established Sandbox Workers were **not modified**.

### Remaining release blockers

- Complete a real end-to-end **isolated Pre-production HTTP** acceptance test through an approved connectivity path; do **not** bypass the current tool egress block.
- Independently review the complete Candidate's security and behavior, including signed policy, legacy admin functions and Push Service Worker scope.
- Provision a real Production Turnstile widget/sitekey and server-side secret, host-bound Cloudflare Access, VAPID and required release bindings under the owner's control (not in public GitHub or chats).
- Verify full Production backup, restoration and rollback drill. Then request **separate explicit Production release authorization**.

**Decision remains NO-GO.** Do not infer that Production is ready based on a Preview upload alone.



## Android Push Service Worker scope defect — fixed before release (2026-11-16)

**Security/functional review finding:** The first review-only Candidate mapped the Android Push setup page from `/__stage1671/android-push` to **`/api/v1/admin/push`** (no trailing slash), while its JavaScript registered `/api/v1/admin/push/sw.js` with scope **`/api/v1/admin/push/`**. Because the setup page was outside that scope, Chrome's `navigator.serviceWorker.ready` could remain unresolved, preventing the Push subscription flow from completing even when the module compiles.

**Fix committed to GitHub test branch only:**
- Map the Android Push setup page to **`/api/v1/admin/push/`** (trailing slash) so it is controlled by the registered Service Worker.
- Update the GET router for the page to the same slash-terminated path.
- Explicitly keep this slash-terminated path in `ASC_RELEASE_NEW_PATHS`; the prior filtering of trailing-slash paths would otherwise silently exclude it.
- Preserve the configured hostname gate, Cloudflare Access verification and real Turnstile verification. No real D1, Subscription, Push endpoint, secret, Production or Staging Worker change was made.

**Test evidence:**
- Added `sandbox/production-candidate-route-contract.test.mjs` with 6 checks for page URL, registration scope, script path, route registration, allowlist membership and security gates.
- Added the checks to the existing read-only GitHub Actions workflow `.github/workflows/production-candidate-offline-review.yml`.
- GitHub Actions run <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43870419197> **SUCCESS — 6/6 PASS, 0 FAIL**, including existing manifest and source-hash fail-closed checks.
- Reassembled using the two exact active Cloudflare Worker sources in **private memory**. The resulting corrected Candidate passed independent V8 JavaScript syntax parsing, Source SHA-256 pinning, legacy route retention, Service Worker scope and all previously mandated Sandbox-token exclusion/real-Siteverify/host-guard checks.
- **Corrected Candidate SHA-256:** `757a9211ba6643dd6d388772cbace0aa3dfdfa138610c13de129a6ce6c4941c7`; **151,542 UTF-8 bytes**, **149,944 UTF-16 code units**.
- The previous Candidate SHA `b76138e01e7384d9ba6bd2efe56682af9f323d13a6c128ff51db9232bac4ed9f` is **superseded** and its former Cloudflare Preview compilation does **not** establish that the corrected Candidate was compiled or exercised on Cloudflare.
- The GitHub Manifest differentiates historical Preview evidence from the current corrected Candidate. **Live HTTP runtime verification remains blocked/unverified**, and no retry or bypass of the HTTP egress restriction was attempted.

**Outcome:** Scope error addressed in the review-only Candidate; static route contract tests PASS. Browser-level Push subscription on a Cloudflare-hosted preproduction URL is **not yet observed**. Existing Production NO-GO and independent configuration/backup/authorization gates remain in place.


## Production Access, Turnstile and recovery readiness — audited

Read-only Cloudflare checks found **2 Access applications** but no verified Production host coverage from the returned metadata; **1 managed Turnstile widget matching the Sandbox host**, with no confirmed dedicated Production widget; and Production Worker **without the new Turnstile, Push Access or VAPID bindings**.

Read-only D1 checks for Production, Staging and Sandbox: **quick_check=ok**, **0 foreign-key violations**, Time Travel bookmark available. Independent Production backup/export restoration is **not certified**.

GitHub Actions run **43873600377** passed **28 Node + 7 Python SQLite tests (35/35)** including synthetic fail-closed Release Channel, Turnstile, hostname, Access AUD, admin identity and VAPID/DB configuration checks. These are static/offline tests, not real HTTP acceptance.

Full operator checklist: [Production Access, Turnstile and Recovery Audit](production-access-turnstile-recovery-audit-2026-11-16.md). **Production remains NO-GO** until owner-controlled secrets/policies, approved HTTP testing and independent restore drill are complete.


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
