# ArcScriptCenter — Stage 16.75: Sandbox Cron Retry Predeployment Review

Date: 2026-11-16 (Asia/Bangkok)
Status: **CODE PREPARED, NOT DEPLOYED. NO CRON TRIGGER ACTIVE.**
Production: **NO-GO**.

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
