# ArcScriptCenter — Stage 16.66: Real Turnstile Integration (Sandbox Only)

Date: 2026-11-15 (Asia/Bangkok)
Status: **Deployed; authorized tester reports all four real-key browser contract tests PASS (4/4), screenshot dated 2026-11-15 22:28 Asia/Bangkok.**
Release gate: **Production NO-GO**

## User-configured Widget / Secret binding

- New real Turnstile widget found by Cloudflare API: `ArcScriptCenter - PreRelease Turnstile`, Managed mode.
- Public sitekey `0x4AAAAAAGCDj9GkRoOQYbsL`; widget allows hostname `arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev`.
- User installed `ASC_TURNSTILE_REAL_SECRET` as a secret_text Worker binding. This was verified by name/type only; secret **value was not read, retrieved, displayed, or committed to GitHub**.
- Existing dummy-mode binding `ASC_TURNSTILE_SECRET` and `ASC_TURNSTILE_MODE=sandbox-dummy` preserved. All eight inherited bindings verified.

## Worker deployment

Worker: `arcscriptcenter-merge-sandbox-1658`
Version: `0.5.72.0-real-turnstile-sandbox`
Version ID: `136a3d0d-0b3e-4aa4-9da6-8916c52ef491`
Deployment ID: `b322f788-3b69-464a-b66b-0307bf31bd5d`
Traffic: **100% Sandbox only**.
Previous Worker version `35b67330-4875-40dc-8c56-4b197fcd1615` remains an identified rollback target (recheck bindings on rollback).

## New protected endpoints

`GET /__stage1666/real-turnstile`: a dark-mode browser page at the existing Cloudflare Access-protected Sandbox hostname. It renders genuine Turnstile via the public sitekey, with `data-action=feedback_submit` and token held only in browser memory.

`POST /__stage1666/verify`: a dedicated real-key verification contract. The endpoint:
1. Requires the Access-protected Worker context, expected Sandbox hostname, and a matching same-origin POST.
2. Parses JSON with strict length and type checks; missing token -> **HTTP 400**.
3. Uses **only** `env.ASC_TURNSTILE_REAL_SECRET`, calling the official Cloudflare Turnstile Siteverify API server-side.
4. Rejects invalid/duplicate tokens -> **HTTP 403**.
5. Rejects Siteverify network/HTTP/config failures -> **HTTP 503**, fail closed.
6. On verified tokens, checks `hostname === arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev` and `action === feedback_submit`; mismatch -> **HTTP 403**.
7. Only after all checks returns `HTTP 200` with `{ok:true,verified:true}` as contract response.
8. Never writes Feedback or D1. No token/secret/receipt is sent to the UI results, saved to D1, or put in console logs.

The page includes buttons for four manually triggered checks: genuine token (200), missing token (400), invalid token (403), and reused genuine token (403). A token must first be accepted to enable replay testing. The browser test is **not run automatically**.

Existing `/__stage1664/contract` and the dummy tests remain unchanged except for the new Worker version string in the health assertion.

## Browser tests — confirmed by authorized tester

After Access authentication open:
https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1666/real-turnstile

Observed browser results (user-supplied screenshot; not independently replayed by the assistant):
- **PASS** · Real token / hostname / action · **HTTP 200**
- **PASS** · Missing token rejected · **HTTP 400**
- **PASS** · Invalid token rejected · **HTTP 403**
- **PASS** · Reused token rejected · **HTTP 403**

Total: **4/4 PASS**. These results verify the isolated test verifier's expected HTTP contract on the real-key path. They do **not** certify end-to-end Feedback Submit integration, real-world anti-abuse efficacy, Access rejection of an unauthorized identity, siteverify outage fail-closed behavior, or Production readiness.

If the widget does not render, verify the precise hostname, browser support, and CSP. If genuine token is rejected, verify widget sitekey/secret pairing, `hostname` and `action`. **Do not paste secrets or full Turnstile tokens into GitHub issues or ChatGPT.**

Note that this is a read-only verification surface, **not yet the real Feedback Submit pipeline**. Stage 16.64 synthetic tests used dummy credentials; run regression tests of that page if needed.

## Security boundaries

- New real-key verification path is separate from dummy-mode Feedback Submit; it cannot create cases.
- Existing Cloudflare Access application still guards the Sandbox hostname, with prior authorized browser entry.
- No Production Worker deployments, no Production/Staging D1 writes or restores, no GitHub main changes, no secret key disclosures.
- Production release **NO-GO**. Real-key browser verification is confirmed (4/4); outstanding gates include independent Production backup/restore certification, Access denial tests, fail-closed outage testing, end-to-end Feedback/Appeal and Arcsen integration, and explicit release approval.

Reference: https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
