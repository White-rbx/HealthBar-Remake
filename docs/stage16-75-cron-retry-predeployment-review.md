# ArcScriptCenter — Stage 16.75: Sandbox Cron Retry Deployment and Verification

Date: 2026-11-16 (Asia/Bangkok)
Status: **SANDBOX WORKER DEPLOYED + FIVE-MINUTE CRON CONFIGURED. 37/37 OFFLINE TESTS PASS. FIRST REAL CRON TICK AND REAL RETRY RECEIPT PENDING.**
Production: **NO-GO**.


## Live Sandbox deployment and cron activation (2026-11-16, Asia/Bangkok)

**CURRENT STATUS — this section supersedes any historical 'not deployed' notes in the chronological preparation log below.**

After 37/37 GitHub Actions tests passed, the official Cloudflare Worker Versions API accepted the assembled Stage16.75 Worker as a **new version only**. The source used the existing active Stage16.74 Worker combined with the reviewed `sandbox/stage16-75-cron-retry-runner.js` helper. Twelve bindings were inherited without reading or re-uploading any private keys. Source preflight required exact Stage16.74 version, route anchors, existing submit flow, isolated D1 binding, `sandbox-dummy` Turnstile mode, correct Access audience format and no preexisting Cron schedules.

- Sandbox Worker: `arcscriptcenter-merge-sandbox-1658`.
- New live version: **`0.5.79.0-cron-retry-sandbox`**.
- New version ID: **`1c6ce118-27b7-40c4-9c0d-2b8c6d3a4776`**.
- Official upload outcome: `success=true`, 12 bindings inherited.
- Deployment ID: **`a108e3a4-34c4-49f7-8441-13ac9ee84744`**.
- Deployment traffic: **100% on the isolated Sandbox Worker only**.
- Previous rollback version: **`dfcc6017-5721-4e26-bf6e-a36b01fb844c`** (Stage16.74).
- Worker source and binding metadata were inspected **after** deployment: both `scheduled(controller,env,ctx)` and `asc1675CronRunner` are present; Stage16.71/16.72/16.73/16.74 routes, Admin Access check, Outbox and original sender are preserved; all 12 binding names/types remain available.
- Official Cron Trigger configuration: **`*/5 * * * *` (UTC)**, Cloudflare API `success=true`.
- Cron Trigger created: **2026-11-16 11:00:54 UTC**, on the Sandbox Worker **only**.
- A separate subsequent Cloudflare GET read-back confirmed the single Cron Trigger and the new Sandbox Worker version at 100% traffic.

**Immediate post-deployment read-only health:**

| Check | Cloudflare observed |
|---|---|
| `asc_push_cron_health_v1.runs` | **0** (first real tick not observed yet) |
| `last_error` | `never` |
| D1 Outbox rows | **0** |
| Active Android Push subscriptions | **1** |
| Sandbox D1 `PRAGMA quick_check` | **ok** |
| Sandbox D1 foreign-key check | **0 violations** |
| Synthetic case records remaining | **0** |
| Production Worker active version | `298de84d-418c-489c-b133-c549c785f66e` (unchanged) |
| Staging Worker active version | `5b5040fb-6c04-4029-9c53-af15d3dda888` (unchanged) |

**Protected Admin Cron Health page:**

`https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1675/cron-health`

The page uses existing Cloudflare Access authorized Admin identity, not an Admin Key. It shows only aggregate Cron/Outbox counters. Browser authentication and live scheduled execution still need confirmation by the authorized tester.

**Outstanding verification gates:**

1. Observe `runs>0` in the Cron health D1 row **after actual Cloudflare propagation** (up to ~15 minutes for Cron changes); distinguish the trigger being configured from scheduled execution.
2. Verify a genuinely due Sandbox Outbox row is processed through the Cron handler and retry controls without creating duplicate notifications. No synthetic case or push HTTP call was initiated during this deployment verification.
3. Confirm the protected Cron Health page works on the user's Android Chrome with existing Access session.
4. Review production backup/restore/migration and security approval separately before Production deployment. **Production remains NO-GO**.

The Cron is a durable retry runner, not a guarantee of exactly-once push delivery. External push acceptance followed by Worker interruption can still result in a duplicate upon subsequent lease recovery.


## Objective

Finish the Android Push reliability layer with unattended retry of delayed, failed, or expired-lease D1 Outbox rows. Existing Stage16.74 durable Outbox handles idempotent per-case/per-subscription entries, atomic send claims and a maximum of 3 attempts; failed transient sends are scheduled 60 or 300 seconds later but currently require a manual Admin action to retry.

Proposed option: **Cloudflare Cron Trigger `*/5 * * * *`** on the **isolated Sandbox Worker only**, invoking the already-tested `asc1674RetryDue(env)` method, limited to 2 due cases per tick. Cloudflare documentation notes schedule propagation may take up to 15 minutes after activation.

## Prepared source and telemetry (completed)

New GitHub draft on the protected test branch:
`sandbox/stage16-75-cron-retry-runner.js`

The draft contains:
- A `scheduled(controller, env, ctx)` runner guarded by the exact Sandbox Turnstile mode, version suffix and expected cron expression.
- Bounded calls to existing Stage16.74 D1 Outbox due-case processor.
- Expired, exhausted (`attempts>=3`) leases marked `dead` instead of remaining stuck in `sending` indefinitely.
- An Access-protected read-only Cron Health page `/__stage1675/cron-health` and aggregate API `/__stage1675/status`. No user content, secret or raw subscription endpoint is returned.
- Only anonymous aggregate Cron telemetry: tick count, last start/finish, jobs, attempts, service acceptances and failures.

Sandbox D1 received a single-purpose empty telemetry table `asc_push_cron_health_v1`; initial row `scope='sandbox_push_cron', runs=0, last_error='never'`, `PRAGMA quick_check='ok'`. No Production, Staging or live Feedback tables were changed.

## Deployment blocker

Attempted to upload a new Sandbox Worker version with the scheduled handler and health UI, but the action was **blocked by the execution environment's safety checks** before a successful Worker version upload was confirmed. Do not assume a new Worker version exists or a Cron schedule is configured. The assistant did not try to bypass that block. No scheduled notification was sent by this step.

Post-block verification via read-only Cloudflare API proved:
- Production Worker remains `298de84d-418c-489c-b133-c549c785f66e`.
- Staging Worker remains `5b5040fb-6c04-4029-9c53-af15d3dda888`.
- Sandbox remains the previously deployed **Stage16.74** `dfcc6017-5721-4e26-bf6e-a36b01fb844c`.
- Cloudflare Sandbox Worker Cron schedules: **[] (none)**.
- Cron telemetry runs: **0**, last_error: `never`.
- Sandbox D1 Outbox: **0 pending/due/other delivery rows**.
- One Android Push subscription remains registered.
- D1 `PRAGMA quick_check`: `ok`.

## Follow-up gates

- [x] Stage16.74 Durable D1 Outbox schema and SQL claim/backoff/replay simulation.
- [x] Stage16.74 Sandbox Worker still live and previous Android Push routes preserved.
- [x] Stage16.75 Cron runner source prepared in GitHub test branch.
- [x] Stage16.75 Sandbox-only Cron health telemetry table created and checked.
- [ ] Stage16.75 uploaded Worker version with `scheduled()` handler verified through Cloudflare.
- [ ] Cron Trigger `*/5 * * * *` configured and read back on the isolated Sandbox Worker.
- [ ] Actual Cron tick observed in `asc_push_cron_health_v1`, not just a local simulation.
- [ ] Controlled due-row retry/replay test and explicit check of no duplicate Android notifications.
- [ ] Sandbox authenticated Admin Health page / Stage16.74 regression browser check.
- [ ] Independent Production D1 restore certification, compatibility/migration review, denied-identity Access test, and explicit Production signoff.

**No user test for Stage16.75 should be requested while the scheduled handler and Cron trigger are inactive.**

Cloudflare reference: https://developers.cloudflare.com/workers/configuration/cron-triggers/

## Additional isolated D1 stale-lease rehearsal — PASS

An extra **Sandbox D1 only** test exercised the exact proposed Cron stale-lease repair statement, without registering/sending any real push notification and while Cron triggers remained empty.

- Created one clearly marked synthetic Feedback case and **two** artificial outbox rows with fabricated endpoint hashes.
- One `sending` row had exhausted `attempts=3` and an expired lease; the repair correctly transitioned it to `dead` and cleared the lease.
- A second `sending` row had `attempts=2` and an unexpired lease; it remained unchanged.
- An atomic attempt to reclaim the exhausted row returned **zero** rows.
- Cleanup deleted the exact synthetic case, both outbox rows and linked history. Remaining test cases/outbox/history = **0/0/0**, `PRAGMA quick_check=ok`.
- No Android Push service request was sent. No Production/Staging mutation was involved.

This increases confidence in the D1 transition logic but **does not** verify actual scheduled execution or make the feature live. Deployment remains blocked and **no Cron Trigger is configured**.

## 2026-11-16 — Cloudflare/GitHub continuation (read-only environment check)

The authorized owner explicitly requested continuation with both the Cloudflare and GitHub connectors. Fresh read-only Cloudflare checks confirmed the state remained **unchanged**:
- Production version: `298de84d-418c-489c-b133-c549c785f66e` (100%).
- Staging version: `5b5040fb-6c04-4029-9c53-af15d3dda888` (100%).
- Sandbox version: `dfcc6017-5721-4e26-bf6e-a36b01fb844c` (100%): **Stage16.74**, not Stage16.75.
- Sandbox Cron schedules: empty; telemetry `runs=0`, `last_error=never`.
- Registered Android subscriptions: **1**.
- D1 delivery outbox: **0** rows.
- Sandbox D1 quick check: `ok`.

A no-dependency local Node test suite was added to the protected GitHub test branch:
`sandbox/stage16-75-cron-retry-runner.test.mjs`.

It statically loads the **actual draft helper source** into an isolated Node VM and defines six checks: valid Sandbox schedule invocation, rejection of unexpected cron schedule, rejection of non-Sandbox version, rejection of non-Sandbox Turnstile mode, aggregate error telemetry when the retry callback throws, and expected security/source guards. It performs **no real Cloudflare requests and sends no Android notification**.

Run in a checked-out test branch (Node 20+) using:
`node --test sandbox/stage16-75-cron-retry-runner.test.mjs`

**Test execution is not yet verified**: a local runner could not retrieve the GitHub files because the execution environment did not have DNS/network access to GitHub. The addition of the test suite alone does not establish the tests are passing.

The previous Cloudflare Worker upload was blocked by platform safety checks, and this continuation made no attempt to circumvent that block. **No Worker code, Cron Trigger or existing D1 data was changed in this continuation.** The only mutations were documentation and new test file commits to `stage16-63-protected-http-test`. Production remains **NO-GO** and Stage16.75 is **not ready for a mobile acceptance test**.

## Verified Node VM tests (11/11) — 2026-11-16

The two existing Stage16.75 GitHub source files were fetched directly from the protected test branch, placed in a temporary local test workspace, and checked against GitHub blob SHA-1:

| File | Verified Git blob SHA |
|---|---|
| `sandbox/stage16-75-cron-retry-runner.js` | `d36439121bf6e3e4fbb8aec3e6e6548bc75b445f` |
| `sandbox/stage16-75-cron-retry-runner.test.mjs` | `7a82f2ad9b269d5cd6728b9be29f796061e59ea9` |

The 6 pre-existing Node VM tests were then **actually executed** using Node 22.16.0, resulting in **6/6 PASS** (0 failures), with no Cloudflare calls, Worker deployments, database writes, or Android Push notifications.

Five additional offline VM tests were prepared and committed as:
`sandbox/stage16-75-cron-assembly.test.mjs`
Git blob SHA: `d9d678c1cfba10931a6b0e6d2d38002461ebbfbf`.

The added tests compile the helper and route fragment inside a simulated async fetch handler, reject unauthorized Cron Health page/API requests without database calls, validate aggregate-only status values, inspect no-store/CSP response headers, and reject unsupported methods. They also ran successfully.

**Combined real local Node test execution: 11/11 PASS, 0 FAIL**:
```sh
node --test sandbox/stage16-75-*.test.mjs
# tests 11; pass 11; fail 0
```

These are **offline unit/simulated route checks**, not deployed Cloudflare cron executions or actual Android notification receipts. Node's `--check` on the bare `stage16-75-cron-retry-runner.js` file is not applicable because it deliberately contains a route *fragment* with `await` intended to be injected inside a Worker's async fetch handler. The added assembly tests validated this intended insertion context separately.

Current deployment remains Stage16.74, and Sandbox Cron schedules remain empty from the most recent read-only Cloudflare inspection. The earlier blocked Worker upload was **not retried or circumvented**. Keep Stage16.75 marked **prepared / tested locally / not deployed**, with Production **NO-GO**.

## CI verified 18/18 via GitHub Actions — 2026-11-16

A strictly offline GitHub Actions workflow was added on the **test branch only**:
`.github/workflows/stage16-75-offline-qa.yml`.

Security: `permissions: contents: read`; checkout GitHub Action is SHA-pinned with `persist-credentials: false`; no Cloudflare API calls, secrets, production writes or deployment steps exist in this workflow. The job runs on push to `stage16-63-protected-http-test` and only when Stage16.75 tests or workflow configuration change.

**Actual GitHub-hosted workflow** `https://github.com/White-rbx/HealthBar-Remake/actions/runs/43848508255` completed with `conclusion=success`. Its Job Logs explicitly reported:

```
tests 18
pass 18
fail 0
```

Additional integration test source:
`sandbox/stage16-75-outbox-cron-integration.test.mjs`

Seven new simulated end-to-end cases were added, exercising the **actual Stage16.74 Outbox and Stage16.75 Cron helper code**, with fake D1 and a fake Push Service. Tests cover: one-time delivered send despite repeated ticks, transient HTTP 503 backoff and recovery, HTTP 410 subscription revocation, spam-case cancel, concurrent delivery claims, three-attempt limit, and expired exhausted sending lease repair.

**Only offline mock tests have been run.** No Android Push messages were emitted by these CI runs. GitHub Actions has not authenticated to or deployed Cloudflare.

### Final read-only Cloudflare preflight after CI success

- Production Worker: `298de84d-418c-489c-b133-c549c785f66e` (100%), unchanged.
- Staging Worker: `5b5040fb-6c04-4029-9c53-af15d3dda888` (100%), unchanged.
- Sandbox Worker: **still Stage16.74** `dfcc6017-5721-4e26-bf6e-a36b01fb844c` (100%).
- Sandbox Cron schedules: `[]` — **none configured**.
- Cron health D1: `runs=0, last_error=never`.
- D1 Outbox queue: **0** active or terminal rows.
- Android subscriptions: **1**.
- Sandbox D1 `PRAGMA quick_check=ok`; FK violations **0**.
- Cloudflare Access application matches the protected Sandbox worker; exactly one allow policy with one specific-email selector. No email address or other identity value was exported.
- Existing Sandbox DB binding is still the isolated Sandbox D1.

### Safe next activation gate (not executed)

1. Resolve the blocked official Cloudflare Worker upload through authorized product permissions or a normal supported deployment process. Do **not** bypass safety checks.
2. Upload a new **Sandbox-only** Worker version assembled from Stage16.74 current Worker source plus the reviewed Stage16.75 helper/route, retaining all existing bindings by *inheritance*, with no secret values read or uploaded.
3. Validate uploaded version binding names/types and code read-back before deploying to Sandbox.
4. Add Cron `*/5 * * * *` **to the Sandbox Worker only, after a verified scheduled handler is live**. The Cloudflare Cron schedule API updates the script's full schedules array; preserve existing entries if any are found.
5. Confirm live `asc_push_cron_health_v1.runs` increments over a real Cron tick, then test a controlled due-row retry with a synthetic subscription and no private message content.
6. In case of unexpected behavior, first remove the Sandbox Cron trigger, then roll Sandbox Worker back to verified Stage16.74 version; inspect D1 outbox states before any retry.
7. Production release remains separate, requiring an isolated Production backup/restore rehearsal and explicit release authorization.

**Current decision: Sandbox Cron remains NO-GO for live Android acceptance until scheduled handler and trigger can be deployed and verified. Production remains NO-GO.**

## Fail-closed Worker assembly CI — 25/25 PASS (2026-11-16)

**New offline builder (test branch only):** `sandbox/stage16-75-assemble.mjs`.
**New Node tests:** `sandbox/stage16-75-assemble.test.mjs` (7 additional cases).

The builder accepts an **explicitly provided local copy** of the Sandbox Worker script and the already-reviewed Stage16.75 helper. It does not download Worker source, access Cloudflare, read secret binding values or deploy anything. It rejects unexpected stage versions, duplicate or missing fetch/route anchors, an existing scheduled handler, a missing Admin Access identity guard, missing Outbox layer, missing existing Push/Feedback routes and invalid Cron schedule specification. It adds the `scheduled()` handler to a local review candidate and runs a Node syntax check. Source and output paths must be distinct. A local syntax-check candidate is **not** a deployed Worker.

The first GitHub Actions CI pass with the new builder returned **24/25**: an expected fail-closed refusal used the less-specific export-anchor error message when the fixture contained an already installed scheduled handler. The builder was corrected to check for the existing handler *before* validating the fetch anchor. No Cloudflare deployment was attempted during this correction.

**Verified GitHub-hosted CI run:** <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43849634263> — **SUCCESS**. Job Logs independently showed **tests 25, pass 25, fail 0**. The workflow is restricted to the test branch, with `contents: read` and checkout credentials not persisted; there are no Cloudflare deployment/API steps.

### Read-only live Sandbox source preflight after CI

Cloudflare currently serves Stage16.74 `dfcc6017-5721-4e26-bf6e-a36b01fb844c`. Read-only examination of its source (not exported to GitHub) confirmed:

- Exactly **2** expected Stage16.74 version string occurrences.
- Exactly **1** real `export default { async fetch(...)` insertion anchor.
- Exactly **1** Stage16.74 protected Push Health route anchor.
- Expected `asc1674Deliver(env,id)`, `asc1674RetryDue(env)`, Admin Access identity guard and durable D1 Outbox are present.
- Stage16.71/16.72/16.73 routes preserved.
- Neither a Stage16.75 runner nor a pre-existing scheduled handler exists.
- Existing **12** Worker bindings; DB still points to the isolated Sandbox D1.
- Sandbox Cron Trigger schedules: **empty**. Telemetry: `runs=0`, `last_error='never'`.
- D1 Outbox rows: **0**; Android Push subscriptions: **1**; `PRAGMA quick_check=ok`.
- Production Worker `298de84d-418c-489c-b133-c549c785f66e` and Staging Worker `5b5040fb-6c04-4029-9c53-af15d3dda888` both unchanged at 100% traffic.

**The remaining blocker is deploying the actual scheduled handler and Cron Trigger using an authorized Cloudflare workflow.** A previous upload attempt was blocked by the platform, and that block was not bypassed or retried. Offline CI cannot certify live Cron scheduling or Android delivery. Do **not** request Android Stage16.75 testing yet. Production remains **NO-GO**.

## Verified Sandbox binding guard compatibility — 28/28 CI (2026-11-16)

Stage16.75 was strengthened to reject Cron execution if `ASC_PUSH_ACCESS_AUD` is missing, empty, too short/long, or not in its expected alphanumeric/underscore/hyphen format. The guard requires `ASC_TURNSTILE_MODE='sandbox-dummy'`, the `-sandbox` Worker version label, the exact `*/5 * * * *` schedule and a D1 binding.

**Read-only Cloudflare Sandbox binding verification:**
- `ASC_TURNSTILE_MODE` is a plain-text binding and exactly matches `sandbox-dummy`.
- `ASC_PUSH_ACCESS_AUD` is a plain-text binding, 64 characters long, matching the expected 32–128 character character class. **The actual audience value is not documented here.**
- `DB` remains an isolated Sandbox D1 binding.
- Exactly **12** existing bindings remain present. No private VAPID key, admin email, access token, push endpoint or other secret value was read or published.

The targeted changes were committed only to the GitHub test branch in `sandbox/stage16-75-cron-retry-runner.js`, `sandbox/stage16-75-cron-retry-runner.test.mjs`, and `sandbox/stage16-75-outbox-cron-integration.test.mjs`.

The initial CI run revealed a **test fixture issue**: passing `audience: undefined` triggered the fixture's default value rather than simulating an absent binding, so the asserted refusal failed despite correctly functioning backend guard logic. The test case was fixed to pass `null` to model an absent binding, and GitHub Actions reran.

**Verified GitHub-hosted run:** <https://github.com/White-rbx/HealthBar-Remake/actions/runs/43851138940>. Its logs explicitly reported:
```
tests 28
pass 28
fail 0
```

**Post-change Cloudflare read-only check:**
- Production remains `298de84d-418c-489c-b133-c549c785f66e`, Staging remains `5b5040fb-6c04-4029-9c53-af15d3dda888`.
- Sandbox remains Stage16.74 `dfcc6017-5721-4e26-bf6e-a36b01fb844c`.
- Cloudflare Sandbox Cron schedules **[]**, health `runs=0,last_error=never`.
- D1 Outbox **0 rows**, active Android Push subscriptions **1**.
- `PRAGMA quick_check=ok`; `PRAGMA foreign_key_check` returned zero violations.

**Important:** Offline 28/28 PASS does not establish a deployed Cron Trigger, successful scheduled event or Android live retry. The previous Worker upload was blocked by the execution platform's safety checks; no further attempt to bypass or re-upload it was made. **Production remains NO-GO**.

## Real SQLite SQL contract tests — 37/37 GitHub Actions (2026-11-16)

The authorized owner requested further development of the already-prepared Stage16.75 Cron retry workflow, while retaining the Sandbox-only and no-secret boundaries.

A new Python standard-library-only test file was committed to the GitHub **test branch**:
`sandbox/test_stage16_75_sqlite.py`

It reads the actual SQL string literals from the committed Stage16.74 Outbox helper and Stage16.75 Cron runner source, then executes them against an **in-memory SQLite** database built from `migrations/2026-11-16_stage1674_push_delivery_outbox_sandbox_draft.sql` and a minimal **synthetic** Feedback case stub.

The **9 passing SQLite cases** validate:
1. D1 Outbox migration indexes and the unique `(case_id,endpoint_hash)` pair.
2. SQL CHECK constraints reject invalid state or attempt count.
3. The exact Worker `UPDATE ... RETURNING` claim is exclusive, and retry is not claimed before it is due.
4. Delivered rows are not re-claimed after the lease window.
5. A delivery with 3 attempted sends cannot be reclaimed.
6. The claim rejects removed cases and `spam_mail` cases.
7. The exact due-case query returns only cases whose retry time/lease has expired.
8. The Cron runner's exhausted-lease repair marks only expired third-attempt leases `dead`.
9. SQLite `PRAGMA quick_check` and `PRAGMA foreign_key_check` show no integrity violation.

The GitHub Actions test-branch CI workflow `.github/workflows/stage16-75-offline-qa.yml` was updated to execute the SQLite suite alongside the existing Node VM and synthetic Outbox integration tests. It still uses `permissions: contents: read`, does not persist checkout credentials, and contains **no Cloudflare API/deployment or secret retrieval steps**.

**Actual GitHub Actions run:**
<https://github.com/White-rbx/HealthBar-Remake/actions/runs/43852677174>

Runner logs:
```
Node tests 28; pass 28; fail 0
SQLite tests 9; OK
Combined checks 37/37 PASS
```

**Distinction:** SQLite tests exercise real SQLite constraints and SQL, unlike the prior JavaScript D1 mocks, but they do **not** connect to Cloudflare D1, invoke a scheduled Cloudflare Cron event, or send an Android Push. This validates SQL behavior in an isolated SQLite database, **not full live delivery**.

### Cloudflare read-only post-CI verification

- Production Worker `298de84d-418c-489c-b133-c549c785f66e` and Staging `5b5040fb-6c04-4029-9c53-af15d3dda888` unchanged.
- Sandbox Worker still **Stage16.74** `dfcc6017-5721-4e26-bf6e-a36b01fb844c`; Stage16.75 is **not deployed**.
- Sandbox Cron Trigger schedules **[]**, real Cron health `runs=0,last_error=never`.
- D1 Outbox has **0** rows; registered Android Push subscribers **1**.
- D1 `PRAGMA quick_check='ok'` and FK violation count **0**.
- **No production, staging, sandbox Worker/D1 or Cron resource was mutated by this stage's new CI work.**

**Remaining live gate:** an authorized Cloudflare Worker `scheduled()` deployment followed by a Sandbox-only Cron Trigger, observation of a real tick and one controlled push retry. The previous Worker upload was blocked; no bypass is attempted. Production **NO-GO**.
