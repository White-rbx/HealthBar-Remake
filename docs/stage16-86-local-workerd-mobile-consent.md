# ArcScriptCenter — Stage 16.86: Local Workerd D1 QA + Mobile Consent Reference

Date: 2026-11-17 (Asia/Bangkok)
Base: Stage 16.85 Pairing Security Sandbox.
Status: **Local Miniflare/workerd CI tests PASS. NO Worker or consent page deployed.**
Scope: test fixtures only; no real user, OAuth application, API tokens or client identity.

## Tested in the actual Workers JavaScript runtime (locally)

Cloudflare recommends runtime-level testing with Miniflare or its Workers Vitest integration. This stage adds a minimal, deliberately non-deployable Worker entry and a real local D1 binding inside a `workerd` process started by Miniflare. GitHub Actions sends simulated HTTP requests to the locally dispatched Worker.

Files:
- `sandbox/stage16-86-test-worker.mjs`: guarded Worker fixture importing **the same** Stage16.85 D1 rate limiter. Hardcodes the `start` action and accepts only local-test server binding values. Not a public API.
- `sandbox/stage16-86-runtime/package.json`: isolated Miniflare dependency.
- `sandbox/stage16-86-runtime/runtime.test.mjs`: Node tests, local workerd+D1 schema, and simultaneous request assertions.
- `.github/workflows/stage16-86-workerd-runtime.yml`: test-only Actions workflow, no deployment step, no Cloudflare credentials.

Observed GitHub Actions workerd test:
- 12 concurrent HTTP POSTs through the local Worker with a per-network limit of 4.
- **4 HTTP 200**, **8 HTTP 429**, and two HMAC-hashed D1 rate buckets each counted 4.
- Wrong fixture authorization header returned 403 without consuming D1 quota.
- Unknown path and unsafe method returned 404; no private data or network identifier leaked.
- A subsequent request after the quota returned 429.

IMPORTANT: This tests the real Workers **runtime locally**, not the hosted Cloudflare edge. The local Miniflare version supported a maximum compatibility date of **2026-08-06** during the run; the connected staging Worker had compatibility date **2026-11-13**. The fixture uses the supported older date; hosted runtime validation is STILL REQUIRED. Do not claim this is equivalent to live deployment.

The network identity used in the fixture is a fixed server-side synthetic value. It does not implement a real trusted Cloudflare network identity adapter. The HMAC secret is a public **test fixture value only**, never suitable for deployment.

## Optional browser-only consent UX reference

Files:
- `sandbox/stage16-86-browser-demo/index.html`
- `sandbox/stage16-86-browser-demo/app.js`
- `sandbox/stage16-86-browser-demo/static-safety.test.mjs`

English-language, mobile-readable static demo (all visible prompts, warnings, buttons, and error messages), NOT intended to replace the owner's ExperienceSettings/Arcsen custom UI design:
1. User manually enters the code shown in their own Arcsen device.
2. The same-origin browser POST to `/pair/browser/preview` obtains a 60-second browser-only confirmation token, but only with an already verified server session.
3. User manually retypes the code into an empty second field and checks an unchecked-by-default own-device consent checkbox.
4. Same-origin browser POST to `/pair/browser/approve` includes `confirmedCode` and `acknowledgeOwnDevice:true`.
5. Success gives only non-privileged pairing approval; no OAuth token or private Roblox UserId enters Luau.

The demo includes an English-only text regression test and uses textContent (not HTML insertion), stores browser-only confirmation challenges only in JS memory, uses same-origin credentials, and does not embed or call third-party scripts. This demo is code in a GitHub branch and is **not hosted**, not connected to live OAuth and not certified against phishing.

## Remaining blockers

- No official Roblox OAuth App or live browser login. Provider eligibility and ID verification requirements must be followed without bypassing them.
- No hosted Cloudflare Worker deployed, protected live secret, or authoritative Cloudflare edge network identification adapter configured.
- No server-validated binding between the untrusted Luau executor and the verified Roblox browser subject. Even a browser-approved pairing code **cannot prove the Luau executor runs under that Roblox account**. Do not grant private Violation History, account-bound Appeal write access or admin privileges from a pairing boolean.
- No Android E2E QA or live browser consent UX security review.
- No Production backup/restore, migrations or deployments. Production and existing STAGING D1 databases unchanged.
- Feedback & Appeal Rules continue to have **no additional account-age gate**.

## Suggested next Stage 16.87

Complete a trust-boundary review and implement a **restricted isolated Sandbox Worker**, with trusted edge metadata, protected secrets and rate limiting only after validation. Separately resolve legitimate Roblox OAuth app eligibility and whether account-specific authorization can be supported safely for the untrusted mobile client.

## Official references

- https://developers.cloudflare.com/workers/testing/miniflare/writing-tests/
- https://developers.cloudflare.com/workers/testing/miniflare/storage/d1/
- https://developers.cloudflare.com/workers/testing/
- https://developers.cloudflare.com/d1/worker-api/prepared-statements/

**STAGING + PRODUCTION unchanged; Stage16.86 is safe for code review, not for live authentication.**
