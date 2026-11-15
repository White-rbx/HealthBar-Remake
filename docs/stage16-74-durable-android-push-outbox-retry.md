# ArcScriptCenter — Stage 16.74: Durable Android Push Outbox + Admin Retry

Date: 2026-11-16 (Asia/Bangkok)
Status: **Sandbox deployed; schema/atomic retry dry run and deployed code read-back PASS. Browser/Android regression test after this change PENDING.**
Production: **NO-GO**.

## Goal and release boundaries

Stage16.73 demonstrated two successful genuine Turnstile-gated synthetic Feedback/Appeal submissions, two accepted FCM sends, two synthetic cleanups, and Android Chrome notifications observed by the authorized tester in both foreground and background-app situations. The earlier sender had no durable queue: it used `ctx.waitUntil()`, attempted one send, and advanced a per-subscriber high-water cursor on success. It could lose a notification on transient failure and could start overlapping sends for the same event.

This stage adds a **Sandbox-only D1 Delivery Outbox** and an Access-protected **manual retry console**. The Production Worker, Staging Worker, their D1 schemas and GitHub `main` remain unchanged. Existing secret values, subscription endpoints and the approved Admin email were not retrieved or written to GitHub.

## Deployment

- Sandbox Worker: `arcscriptcenter-merge-sandbox-1658`
- Version: `0.5.78.0-durable-push-outbox-sandbox`
- Active version ID: `dfcc6017-5721-4e26-bf6e-a36b01fb844c`
- Deployment ID: `af17dfae-f714-432a-857f-b14d221b0496`
- Previous Sandbox version / rollback target: `70fdbeae-eeee-40f1-be6d-5007a21c7a43`
- Existing **12 Worker binding names/types** inherited.
- New Sandbox D1 table: `asc_push_delivery_outbox_v1`, plus `idx_asc_push_outbox_due_v1` and `idx_asc_push_outbox_case_v1`.
- Database: Sandbox-only `asc-stage1658-prodlike-20261115`, ID checked with Worker DB binding and Time Travel bookmark before DDL.

Implementation source on protected test branch:
`sandbox/stage16-74-push-outbox-helpers.js`

Draft schema, **not authorized for Production**:
`migrations/2026-11-16_stage1674_push_delivery_outbox_sandbox_draft.sql`

### Durable delivery state

Outbox uses `(case_id,endpoint_hash)` as its unique key, so the same event cannot create duplicate queue rows for the same registered subscription. It stores **no raw Push Endpoint** (which remains only in the existing protected subscriptions table), user message text, receipt, key, or email address.

The existing `fcSubmit` D1 transaction now inserts durable pending outbox records as part of the same **D1.batch** that writes the case and quota records. Therefore, a successful committed submission does not rely solely on the post-response `waitUntil()` call to create its delivery record. The existing post-commit `ascStage1671Broadcast` entry point remains intact, now backed by the outbox, and is also used by Stage16.72 and Stage16.73 synthetic push tests.

Worker uses an atomic `UPDATE ... RETURNING` to claim a specific `case_id + endpoint_hash` delivery only when its lease is available. State machine: `pending → sending → delivered` on FCM acceptance; transient failure causes `retry` after **60 seconds** or **300 seconds**; maximum **3 attempts**; permanent rejection or exhausted attempts becomes `dead`; removed/spam cases become `canceled`. A leased send may be retried when the lease expires.

Acknowledged sends update the legacy subscriber event cursor for backwards compatibility, but **outbox state** is the true per-case/per-device deduplication guard. A 404/410 FCM rejection revokes the associated invalid subscription. Network ambiguity can still cause duplicate push notifications if FCM accepts a send and the Worker crashes before recording `delivered`; this is **not exactly-once delivery**. D1 persistent outbox plus bounded lease narrows the risk.

Sandbox Stage16.72 and Stage16.73 synthetic cleanup paths were extended to remove exact linked Outbox rows when deleting their generated synthetic case/history records.

### Access-protected Admin monitoring

`GET https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1674/push-health`

Additional endpoints:

- `GET /__stage1674/status`: returns only aggregate state counts, registered-device count and due count.
- `POST /__stage1674/retry-due`: requires matching Cloudflare Access Admin identity, exact Sandbox host, same-origin JSON body `{"confirm":true}`, and user confirmation in the UI. It manually processes at most **two due cases** per invocation using the same outbox claims.

No Admin Key needs to be entered in this Android Push page. The allowed Access account check remains unchanged. No raw subscription endpoint, personal identifier, message text, secret or event-by-event item details are returned to the browser.

**Important scope limitation:** The first push attempt still runs automatically after submission via `ctx.waitUntil()`. A failed send is persisted with a next retry time but **will not retry itself when no Admin action occurs**, because no Cron Trigger or Queues consumer has been installed yet. Manual `Retry Due Now` recovers those due cases. Fully unattended retries are a separate Stage16.75 option after costs/operational permissions and additional testing.

## Verification performed

1. Read-only Sandbox environment preflight confirmed named D1 binding, active Worker version and Time Travel bookmark. Production/Staging not changed.
2. Created the D1 outbox table and two indexes in isolated **Sandbox only**. `PRAGMA quick_check` returned `ok`; `PRAGMA foreign_key_check` returned no violations.
3. Synthetic D1 **dry run** without making any Push HTTP request verified:
   - Inserting the same `(case_id,endpoint_hash)` twice leaves exactly one row.
   - Atomic exclusive claim succeeds once; an overlapping claim returns zero rows.
   - Retry claim before due time fails, claim at due succeeds, attempts increment to 2.
   - A delivered row cannot be claimed again.
   - Cleanup removed exact synthetic case, linked history and delivery row (all **0** afterward).
   - D1 integrity quick check still `ok`, no FK violations.
4. Uploaded Worker version `dfcc6017-5721-4e26-bf6e-a36b01fb844c`, verified 12 inherited bindings and secret types, then deployed to Sandbox at **100%**.
5. Read-back static source inspection confirmed `fcSubmit` batch includes outbox inserts, broadcaster delegates to outbox, three-attempt cap and lease guard, 60s/300s backoff, 404/410 invalid subscription handling, delivered terminal state, exact Stage16.72/16.73 test cleanup and Access-admin-protected retry/status route.
6. Before manual user testing, Outbox state counts were **empty** (no pending deliveries), existing active Android subscriptions = **1**, D1 quick check `ok`, orphan Feedback history count = **0**.

**Not yet demonstrated:** a new successful real Turnstile Feedback/Appeal submission after Stage16.74's Worker change, native Android OS receipt after that change, retry status API via actual Access-authorized browser, or a real transient FCM failure/recovery. The D1 state-machine dry run is not the same as live HTTP retry verification.

## Safe user acceptance check

Open the protected Admin Push Health page on Android Chrome. Verify that the state counts are displayed and `Registered Android devices: 1` appears, without supplying any Admin Key. Then open the existing Stage16.73 genuine Turnstile page and submit **one labeled synthetic Feedback test**, verify the Android Notification, and inspect the Stage16.74 Admin Push Health counts. Stage16.73 is designed to clean its own synthetic case/history/Outbox rows after send, so the outbox will normally show 0 after it finishes. A D1 post-test read-only check should confirm no leftover synthetic rows or failed attempts.

Do not press the manual retry button unless due items exist, and do not share Access cookies, private keys, Push subscription endpoints or other credentials in screenshots.

## Release gates

- [x] Stage16.71 native Android OS Push acceptance / observed receipt.
- [x] Stage16.72 delayed synthetic background Push / D1 accepted 1 of 1 / cleaned.
- [x] Stage16.73 genuine Turnstile synthetic submit / FCM accepted 2 of 2 / Android user-confirmed / cleaned.
- [x] Stage16.74 durable D1 Outbox schema and SQL state-machine dry run.
- [x] Stage16.74 Sandbox Worker deployment and static code checks.
- [ ] Stage16.74 actual Access-authorized Admin page and live Feedback → Push regression test.
- [ ] Stage16.75 unattended retry scheduling (Queues or Cron) and lease recovery tests, pending design/permission.
- [ ] Authenticated identity not allowed by Access email policy — browser denial check.
- [ ] Independent Production D1 export/isolated restore, Worker/schema migration review, release rollback plan and explicit authorized release signoff.

**Production remains NO-GO.**

References: https://developers.cloudflare.com/workers/runtime-apis/context/#waituntil ; https://developers.cloudflare.com/workers/platform/storage-options/
