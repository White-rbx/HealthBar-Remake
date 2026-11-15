# ArcScriptCenter — Stage 16.67: Genuine Turnstile × Feedback & Appeal Integration

Date: 2026-11-15 (Asia/Bangkok)
Scope: **Cloudflare Access-protected Sandbox only**. Production stays **NO-GO**.

## 1. Implementation — deployed, awaiting user browser tests

Worker: `arcscriptcenter-merge-sandbox-1658`
Code version: `0.5.73.0-feedback-real-integration-sandbox`
Cloudflare version ID: `c23843e8-f6bb-4f2f-a254-cf0424070a67`
Deployment ID: `ab967514-bdd3-4f5c-9591-75cb4f325f38`
Traffic: **100% Sandbox**.

The new Worker version was uploaded after matching the previously deployed version, inherited **all eight existing bindings**, and was deployed only after verifying binding names/types and exact active version. The existing Stage 16.64 dummy-test and Stage 16.66 real-token contract endpoints remain in place.

New page: `GET /__stage1667/integration`.
New real-key submit endpoint: `POST /__stage1667/submit`.
New simulated fail-closed endpoint: `POST /__stage1667/simulated-outage`.

Open after Access login:

https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1667/integration

## 2. Genuine Turnstile Feedback/Appeal integration

- Page uses the registered Managed Turnstile public sitekey, with separate actions `feedback_submit` and `appeal_submit`.
- User must explicitly confirm each synthetic record creation.
- New submit endpoint requires Access context, exact Sandbox hostname, same-origin browser POST and server-selected `verifyMode='real-stage1667'`.
- The server uses **only** `env.ASC_TURNSTILE_REAL_SECRET` and calls Siteverify before existing quota tracking and D1 inserts.
- Verifies Siteverify `success`, exact hostname, and the correct action for Feedback vs Appeal.
- Returns 400 for missing/invalid-shape tokens, 403 for invalid/replayed/wrong-context tokens, and 503 when Siteverify is unavailable. No D1 writes on verification failure.
- Validated requests reuse the existing `fcSubmit` implementation, preserving anonymous quota handling, D1 insert logic, receipt generation and receipt-scoped status/edit/remove endpoints.
- Existing `/api/v1/feedback/submit` still defaults to the original dummy Turnstile verification on Sandbox. No untrusted request-field can select the verification mode; only the explicitly guarded server route chooses the real mode.
- Client retains temporary synthetic `id`/`receipt` only in browser memory and attempts emergency soft removal if a later lifecycle step fails. The results UI does not reveal tokens, receipts, client keys, or secrets.
- Synthetic rows are **soft-deleted**, not physically removed; review and clean up their exact marked rows in Sandbox D1 after successful browser confirmation. Quota rows are not reset by these tests.

**No changes to Production code, Production D1 or Production credentials.**

## 3. Test plan — awaiting browser results

The user should complete both real Turnstile widgets and run these two user-confirmed synthetic lifecycle cases:

| Case | Expected status |
|---|---|
| feedback Submit | HTTP 201 |
| feedback Status | HTTP 200 |
| feedback Edit | HTTP 200 |
| feedback Soft Remove | HTTP 200 |
| feedback Removed receipt denied | HTTP 404 |
| appeal Submit | HTTP 201 |
| appeal Status | HTTP 200 |
| appeal Edit | HTTP 200 |
| appeal Soft Remove | HTTP 200 |
| appeal Removed receipt denied | HTTP 404 |
| Simulated Siteverify outage | HTTP 503 |

**Expected total: 11/11**. This is a target, not a claim of observed success.

The simulated outage endpoint injects a server-owned transport failure to exercise fail-closed behavior. It does not call actual Siteverify or D1, cannot be chosen via a user-supplied flag, and is confined to the Access-protected Sandbox endpoint. It tests handling of simulated network failures **only**, not a real Cloudflare outage.

If a test fails, record just the case name and HTTP status (never token, receipt, cookie, email, ID, clientKey or Secret). Do not run multiple batches until affected cases and quota are inspected.

## 4. Cloudflare Access denial checks — manual pending

Separate from the authorized happy path:
1. In a new incognito context without an Access session, visit Sandbox health or the Stage16.67 page; Access login/denial should appear **before** protected API JSON or the test page.
2. Use an identity outside the allow rule to verify denial; **do not share login credentials, email addresses or Access tokens with the assistant**.
3. After authenticating as the allowed tester, verify the page is reachable.
4. The Access dashboard policy and app settings were inspected previously, but browser denial behavior is not yet independently confirmed.

## 5. Production gates

- [x] Stage16.64 dummy HTTP contract — tester confirmed 19/19.
- [x] Stage16.66 real Turnstile read-only contract — tester confirmed 4/4.
- [x] Stage16.66 isolated synthetic D1 restore — pass.
- [x] Stage16.67 real-key integration code uploaded and deployed, eight bindings preserved.
- [ ] Stage16.67 authorized browser Feedback/Appeal lifecycle and simulated fail-closed checks.
- [ ] Cloudflare Access unauthorized and no-session checks.
- [ ] Independently restorable **Production** backup validation.
- [ ] Full Arcsen and browser integration release acceptance.
- [ ] Explicit Production release and rollback authorization.

Release status: **NO-GO**.
