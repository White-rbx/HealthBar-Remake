# ArcScriptCenter — Stage 16.72: Android Background Push Rehearsal

Date: 2026-11-16 (Asia/Bangkok)
Status: **Sandbox Worker deployed, access/route/D1 static checks PASS. Background Android reception still REQUIRES user/device confirmation.**
Production: **NO-GO.**

## Motivation

The owner confirmed receipt of a real Android Chrome OS notification in a screenshot during Stage16.71. That confirmed browser Push reception, **not** that a new Feedback or Appeal triggers a notification after Chrome is backgrounded. Stage16.72 provides a controlled manual way to test precisely this condition without requiring the user to share credentials or submit real personal information.

## What is deployed

- Worker: `arcscriptcenter-merge-sandbox-1658`
- Version: `0.5.76.0-background-push-rehearsal-sandbox`
- Version ID: `33949b4d-e6da-4a9f-8e4a-f33f11ba9e03`
- Deployment ID: `853ff812-b1e4-4099-b0ab-15c5cebe5775`
- Traffic: **100% Sandbox Worker only**
- Previous version: `b712c612-3d36-484a-83e1-5c4a1979b659` available for rollback
- All 12 previous bindings inherited by name/type; no secret values fetched or committed, and no Production or Staging Worker/D1 changes.

Protected test page:

`https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1672/background-push`

### Routes

- `GET /__stage1672/background-push` — authorized admin-only test page, nonce CSP and no cache.
- `GET /__stage1672/status` — admin-only anonymized test state: registered device count, test attempts, push-service acceptance count, cooldown. **Never** returns push endpoints, admin email, secrets or case contents.
- `POST /__stage1672/run` — admin-only, same-origin JSON action `kind='feedback'|'appeal'`. Requires **exactly one** registered Sandbox Android push device. No Admin Key input: authenticates via Cloudflare Access and matching allowed-admin identity, as in Stage16.71.

One test per 120 seconds, server-enforced by atomic D1 `UPDATE ... RETURNING` with time condition.

### Controlled delayed synthetic submission

The user taps a test button, immediately presses Android **Home**, and the Sandbox Worker uses `ctx.waitUntil` to hold the test task for ~12 seconds before doing any send. Cloudflare Workers documentation permits `waitUntil` tasks up to 30 seconds after the response is returned; actual work completion can be affected by runtime limits.

After the delay, the Worker inserts one intentionally synthetic Feedback or Appeal case with server-generated ID and generic non-user description. The existing `asc_feedback_history` INSERT trigger writes a `submitted` event. Stage16.72 calls the **same** `ascStage1671Broadcast` sender that real successful `fcSubmit` calls. The sender now returns counters for attempts and service acceptance without leaking endpoints or tokens; live submission behavior is retained.

The task removes the exact synthetic history and case rows in a `finally` cleanup block. It records `accepted`, `not_accepted`, or `error` in a single-row test-control table, distinguishing push **service acceptance** from Android **device receipt**. Real user quotas are not touched. No real user identity, text, receipt or account data is used.

D1 table created **in Sandbox D1 only**:

`asc_stage1672_test_control`: one row with last test timestamp, status, attempt and acceptance counters; allows cooldown and post-test inspection. Preflight verified Sandbox DB identity, Worker binding and D1 Time Travel bookmark. `PRAGMA quick_check=ok`, no FK violations.

### Safety and scope

- The button is accessible only through the existing Cloudflare Access Worker-level protection AND an exact allowed-admin identity verification.
- The control endpoint is same-origin and content-type validated.
- One device / one synthetic event per 120 seconds; no arbitrary push payload or user-submitted notification text.
- Synthetic record cleanup occurs in `finally` and is restricted to the generated exact ID and synthetic topic.
- Synthetic cases go through D1 `submitted` trigger and the same VAPID broadcast sender. This **does not exercise the real Turnstile + quota + `fcSubmit` validation path**. The user can separately test that through Stage16.67 integration page.
- The service sends only a generic notification. The screenshot remains user-owned and is not uploaded to GitHub.

## Verification evidence (2026-11-16)

**PASS — read-back/static**:
- Sandbox deployment active at 100% of `0.5.76.0`.
- All 12 Worker bindings and same isolated D1 binding present.
- Test HTML decoded correctly, both Feedback and Appeal buttons present.
- Same-origin POST and Access admin checks present.
- 120-second atomic D1 rate-limit guard present.
- 12-second delayed worker execution and existing broadcaster call present.
- Restricted synthetic D1 cleanup present.
- Stage16.67 and Stage16.71 routes preserved.
- D1 `asc_stage1672_test_control`: status `never`, attempts `0`, accepted `0`.
- D1 registered Push Subscriptions: **1**.
- D1 leftover `Stage1672 Synthetic % Push` cases: **0**.
- D1 `PRAGMA quick_check`: **ok**.

**PENDING**:
- Authorized browser opens test UI, taps Test Feedback (or Appeal).
- User backgrounds Android Chrome and confirms whether the native notification appears after the trigger delay.
- Post-test D1 acceptance status and cleanup verified.
- Full real Turnstile Feedback/Appeal submission -> Push -> Android OS reception (separate E2E acceptance).

## How the user can test

1. Android Chrome: open the Access-protected Stage16.72 test URL above; Cloudflare Access should authenticate the authorized admin identity automatically.
2. Press `Test Feedback Push` once, then **immediately press Android Home** (do not close the Android app forcefully).
3. Watch for the generic ArcScriptCenter Chrome Notification after the ~12-second delay. Android battery settings and push service availability may cause delay.
4. Return to Stage16.72 and press `Refresh Status`: `accepted` means FCM accepted it, **not proof the device displayed it**.
5. Wait at least 120 seconds between runs, if testing Appeal separately.

If that passes, open `/__stage1667/integration` in Android Chrome to test one genuine Turnstile-gated synthetic Feedback or Appeal submission and observe push. Those test cases require exact bounded cleanup afterward.

## Release gate

Production remains **NO-GO**. Remaining work includes actual mobile background screenshot confirmation, real submit integration test, safe replay and failure tests, independent Production D1 recoverability, cross-environment Worker/Schema compatibility and authorized release signoff.

Cloudflare source:
https://developers.cloudflare.com/workers/runtime-apis/context/#waituntil
