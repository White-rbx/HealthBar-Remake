# ArcScriptCenter Stage 16.64 — Protected Feedback & Appeal HTTP Acceptance

**Environment:** SANDBOX ONLY, protected by Cloudflare Access. **Production: NO-GO.**

- Worker: `arcscriptcenter-merge-sandbox-1658`
- Worker version: `0.5.71.0-protected-http-tests` (deployed 100%)
- Protected Test Page: `https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1664/contract`
- GitHub branch: `stage16-64-sandbox-feedback-http`
- Sandbox D1: `asc-stage1658-prodlike-20261115`

## Verified platform setup

- Cloudflare Access is bound to this **one Worker** and a reusable policy permits one tester; this does not change the existing Dashboard Access application.
- Worker `workers.dev` is enabled **behind Access**, Worker preview URLs remain disabled.
- The added HTML page has an additional `ctx.access` check that fails closed and a nonce-based Content Security Policy.
- Sandbox database was empty before browser testing (0 cases, 0 histories, 0 follow-up events, 0 quota rows).
- Production Worker, Production Pages and Staging Worker were unchanged.

## Browser test procedure

1. Open an Incognito window with **no** Cloudflare Access session. Visit the protected page. It should show the Access login/denial rather than the test UI or API JSON. Record PASS/FAIL; do not share cookies or credentials.
2. Sign in using the authorized Cloudflare Access identity. Visit the protected test page.
3. Click **Run Safe Tests** (nine read-only/rejection probes): GET health 200, unknown path 404, wrong method 405, malformed submit 400, missing token 400, invalid Turnstile token 403, unknown receipt 404, bad manage operation 400, admin route without Admin Key 401.
4. Check that the results say **9/9 passed**. Share only the safe summary text (no tokens).
5. Only after the safe probes pass, optionally click **Run 2 Synthetic Cases** and confirm. The browser will create one synthetic Feedback and one synthetic Appeal using **Cloudflare's official dummy Turnstile token**. Each case runs submit → status → edit → soft delete → verify inaccessible.
6. The two synthetic records and audit history persist as soft-deleted test fixtures. They **must be purged later using narrowly scoped cleanup on the Sandbox D1 only**. This cleanup is not an automatic part of the browser test.
7. Report PASS/FAIL and HTTP status codes without sharing any Receipt, Client Key, Admin Key, Access Cookie, or authentication details.

## Known limitations

- Live browser tests are **pending** and must not be counted as passed until the tester confirms.
- Turnstile keys are **official dummy test keys**, not real bot protection; no Production release.
- `ctx.access` may not be present in the deployed runtime; if the protected route returns 403 after genuine Access authentication, stop testing and investigate — **never disable Access** as a workaround.
- Siteverify connectivity failures can return 503 instead of expected rejection 403; this is fail-closed, not a pass.
- Positive synthetic tests may consume the separate sandbox quota. Do not repeatedly click if a test fails.
- The current Producer and Arcsen client UI are **not yet integrated** with Turnstile.
- Production D1 backup export-download-import verification remains a release blocker.

## Rollback

Worker `v0.5.70.0-turnstile-sandbox-test` is retained and can be redeployed to the isolated sandbox if Stage 16.64 proves defective. Leave the existing Cloudflare Access application and one-user allow policy in place. Do not edit any Production or Staging resources.
