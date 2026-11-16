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
