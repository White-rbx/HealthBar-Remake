# ArcScriptCenter — Stage 16.73: Real Turnstile Feedback/Appeal → Android Push E2E

Date: 2026-11-16 (Asia/Bangkok)
Status: **Sandbox REAL TURNSTILE → ANDROID PUSH E2E PASS: 2/2 accepted, 2/2 cleaned, user-confirmed Android reception in foreground/background; Production NO-GO.**
Production: **NO-GO**.

## Background

Stage16.72 delayed synthetic test delivered a genuine native Android Chrome notification. The authorized tester provided a screenshot confirming receipt while following the background test steps. Cloudflare D1 independently recorded **one accepted Push**, **one test attempt**, and **zero leftover synthetic Feedback cases/history/orphans**, with `PRAGMA quick_check=ok`. This verifies delayed synthetic Push, but it did not exercise real Turnstile verification or the actual Feedback submit/quota transaction.

Stage16.73 closes that testing gap via a narrow, admin-protected **Real Turnstile-gated synthetic Feedback/Appeal submission**, where the submission passes the same `fcSubmit` and D1 quota paths as real requests, then sends to Android via the same VAPID broadcaster.

## Sandbox-only deployment

- Worker: `arcscriptcenter-merge-sandbox-1658`
- Version: `0.5.77.0-real-turnstile-android-push-sandbox`
- Version ID: `70fdbeae-eeee-40f1-be6d-5007a21c7a43`
- Deployment ID: `fa5a2c18-7cc6-4b16-b333-907ffb1b358b`
- Traffic: **100% Sandbox Worker only**
- Previous version for rollback: `33949b4d-e6da-4a9f-8e4a-f33f11ba9e03`
- Existing 12 Worker bindings preserved by inheritance. The Worker bound to Sandbox D1 `asc-stage1658-prodlike-20261115`, not Staging or Production.
- Production and Staging Worker deployments and D1 databases were not altered.

### Browser test page

`https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1673/real-turnstile-push`

Contains **separate genuine Turnstile widgets** with actions `feedback_submit` and `appeal_submit`, plus buttons:

- **Submit Real Feedback Test**
- **Submit Real Appeal Test**
- **Refresh Test Status**

Access restrictions: Cloudflare Worker-level Access, expected audience, exact approved admin identity, exact Sandbox hostname and same-origin JSON for changing state. Does **not** ask for or display Admin Keys, VAPID secrets, receipts, identities, push endpoints or tokens.

### Protected API

- `GET /__stage1673/status`: aggregate counters, cooldown, subscription count, never endpoints or identifying details.
- `POST /__stage1673/submit`: only `kind` and real Turnstile token from the browser. Requires a single registered Android push device.
- Server generates **all** case fields; user cannot inject topic, description, claimed ID or notification text.
- Real `ascStage1667SiteVerify` checks the token's **hostname** and **action** before any submission D1 write. Server then calls `fcSubmit(internal, env, origin, 'real-stage1667', null)` for the real rate-limit/quota transaction and the D1 history trigger.
- HTTP 201 is returned to browser only once a genuine synthetic submission has been committed, without revealing the case receipt.
- A `ctx.waitUntil` task delays the standard `ascStage1671Broadcast` sender for **12 seconds**, giving Android time to background Chrome. The script then deletes the **exact generated synthetic case and its history only**; no existing user case rows are deleted.
- One test permitted per **120 seconds**, enforced by an atomic D1 `UPDATE ... RETURNING` state claim.
- Submission **does consume normal Sandbox quota counters** because testing the real `fcSubmit` path is intentional; never manually delete or reset shared quota rows.
- The cleanup `finally` path records result `accepted`, `not_accepted` or `error`, plus the number of cleaned synthetic test rows.
- Cloudflare `waitUntil` background work may last up to 30 seconds post-response. If the task is interrupted, residual test rows require a scoped preflight and cleanup review; do not assume that `finally` is guaranteed to execute if the Worker is terminated.

### New Sandbox D1 test state

Created `asc_stage1673_real_push_control`, one row for `real_turnstile_push` with attempts, submitted, accepted, cleaned and cooldown timestamps. Preflight checked Sandbox DB ID, Worker binding and Time Travel bookmark before creating it. Initial D1 quick check `ok`, foreign key check empty, and exactly one Android subscription present.

No real message text or personally identifying data belongs in test cases. No raw Turnstile token or receipt is stored in the control table.

## Verification completed

**PASS (read-back/static, not live browser yet)**

- Current Sandbox Worker deployment resolves to `70fdbeae-eeee-40f1-be6d-5007a21c7a43` at 100% traffic.
- 12 Worker binding names/types present; same Sandbox D1 ID remains bound.
- Embedded HTML decodes correctly and includes both real Turnstile widgets and action labels.
- Browser requests and backend check Access admin identity and same-origin rules.
- Submission route delegates to `fcSubmit(...,'real-stage1667',null)`, using the existing Siteverify logic, genuine quota code and D1 history trigger.
- Delayed task uses the existing broadcaster and deletes history and exact synthetic case in a cleanup block.
- Stage16.67, Stage16.71 and Stage16.72 routes remain present.
- Test-control state initially `never`, attempts `0`, submitted `0`, accepted `0`, cleaned `0`.
- Android device active subscription count: **1**.
- Stage1673 synthetic cases initially: **0**.
- D1 `PRAGMA quick_check`: `ok`.

**PENDING**: an actual authorized Android browser Turnstile test and user-confirmed Android notification, then inspection of D1 acceptance/cleanup outcome. Do not mark the Real Turnstile → Android E2E as PASS yet.

## Tester instructions (Android Chrome)

1. Open the protected Stage16.73 URL; authenticate with existing Cloudflare Access account if needed.
2. Wait for the appropriate Turnstile to show ready; press **Submit Real Feedback Test** once.
3. On the `Real Turnstile accepted` message, press Android **Home** immediately. A push is scheduled around 12 seconds later.
4. Confirm whether the actual Android Chrome system notification appears. Reopen the page and press **Refresh Test Status**.
5. To test Appeal separately, wait at least 120 seconds for cooldown and repeat with **Submit Real Appeal Test**.
6. After the test, have the assistant inspect aggregate Sandbox D1 counters and check for any remaining marked Stage1673 synthetic records; do not share any credentials, Turnstile tokens, Push endpoints, receipts or Admin Key.

## Release gates

- [x] Native Android Web Push test from Stage16.71 — user screenshot confirmed.
- [x] Stage16.72 background synthetic Push — D1 `accepted` plus Android screenshot confirmed; cleanup 0 leftover.
- [x] Stage16.73 real Turnstile Push test route deployed and statically verified.
- [x] Stage16.73 **two real Turnstile-gated synthetic submissions** → Push accepted 2/2 → Android native delivery user-confirmed (both foreground and background app tests), with cleanup 2/2; specific kinds not persisted in the aggregate test counters.
- [ ] Optional kind-specific Feedback-vs-Appeal per-run evidence and true app force-stop behavior (distinct from moving Chrome into the background) are not separately established from the aggregate counters.
- [ ] Independent Production backup export and isolated restore certification, stage-specific D1 migration, Worker compatibility audit, disallowed-identity Access browser test and explicit signoff.

**Production remains NO-GO.**

## Stage16.73 verified Android real-submit results — 2026-11-16 (Asia/Bangkok)

The authorized tester reported: **"ขึ้นแล้ว ผมได้ทดสอบทั้งยังไม่ปิดแอปและปิดแอป (Background App)"** — genuine Android notifications appeared when Chrome was in the foreground and when the browser had been backgrounded. This is a user-confirmed native notification observation. *Moving an app to the background does not by itself establish that notifications survive Android Force Stop.*

Independent **read-only** Sandbox D1 inspection after the tester finished showed:

| Test counter / check | Observed |
|---|---:|
| `asc_stage1673_real_push_control.attempts` | **2** |
| `submitted` (actual `fcSubmit` path with real Siteverify, D1 write and quota) | **2** |
| `accepted` (push-service acceptance; not itself device delivery proof) | **2** |
| `cleaned` (synthetic cases) | **2** |
| `last_result` | `accepted` |
| Active Sandbox Android Push subscriptions | **1** |
| Subscriber `last_sent_event_id` (dedup cursor only) | **43** |
| All remaining `asc_feedback_cases` | **0** |
| All remaining `asc_feedback_history` | **0** |
| Orphaned history rows | **0** |
| `PRAGMA quick_check` | **ok** |
| `PRAGMA foreign_key_check` | **0 violations** |

**PASS:** The Sandbox Real Turnstile `fcSubmit` transaction successfully committed two synthetic submissions and the standard VAPID broadcaster received two success responses; the user confirmed genuine Android notifications for both in-app and background-app testing. Cleanup has zero cases/history orphans remaining. This is **not** a Production test.

**Evidence limitation:** The aggregate D1 control table records counts, not the submission `kind` for each attempt. Therefore the two successful attempts cannot be independently classified as specifically one Feedback and one Appeal using this control table after cleanup. User reported two app *states* tested, not an explicit per-kind breakdown. The existing Stage16.67 test separately covered both Feedback and Appeal lifecycles. Screenshots/credentials, private push subscription endpoint, admin identity, keys, receipts and Turnstile tokens were **not** exported to GitHub.

**Next release gates remain open:** a disallowed-identity Access rejection check, Production-compatible schema/Worker review, independent production backup copied/restored only into an isolated target, operational monitoring/retries and explicit authorization before any Production change. **Production remains NO-GO.**
