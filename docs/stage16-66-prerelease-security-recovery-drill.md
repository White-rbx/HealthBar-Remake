# ArcScriptCenter — Stage 16.66: Real-Key Preflight, Access Review & Isolated Recovery Drill

Date: 2026-11-15 (Asia/Bangkok)
Scope: **Read-only checks for Turnstile and Cloudflare Access; data writes/restoration ONLY in a newly created, disposable D1 test database.** Production and Staging databases and Workers remained unchanged.
Release status: **Production NO-GO**.

## 1. Real Turnstile preparation — BLOCKED (no widget provisioned)

Cloudflare account Turnstile widget list returned `success: true`, `result: []` and `total_count: 0`. There are currently **zero configured widgets** available through this account connection.

A real-sitekey/secret-key validation test therefore **was not performed**. No secret keys were generated, read, displayed, rotated, exported or replaced. Do **not** reuse the official dummy Turnstile test secret as production bot protection.

Next prerelease actions:
1. Use Cloudflare's **Turnstile** dashboard to configure a dedicated **real** widget limited to the exact pre-release hostname. The user should own and manage the secret privately.
2. Keep the secret in a pre-release **Worker secret binding** (not in a public GitHub repo, browser JavaScript, Luau, analytics, or logs). This requires an authorized operator to configure the binding; never paste it into chat.
3. Implement an isolated pre-release browser form that obtains a genuine Turnstile token for `action: feedback_submit` (or a clearly documented equivalent), with sitekey public and secret server-only.
4. Verify via **server-side Siteverify**, check successful responses and expected hostname/action, reject absent/invalid/replayed/expired tokens, and fail closed if Siteverify is unavailable.
5. Ensure test worker is restricted by Cloudflare Access and cannot read or write Production D1. Avoid "real-key" tests on the existing dummy-mode Sandbox.

Reference: https://developers.cloudflare.com/turnstile/get-started/server-side-validation/

## 2. Cloudflare Access preflight — CONFIG VERIFIED, LIVE DENIAL PENDING

Sandbox Access application: `Stage16.63 ArcScriptCenter Sandbox Protected Worker`.
- Type: `self_hosted`.
- Session duration: `1h`.
- Application policy: one `allow` rule matching an email selector, no explicit exclude or require rule.
- The authorized tester previously verified entry through the Access login flow.

The Access user-policy-check API could not evaluate without an authorized user identifier (`HTTP 400 access.api.error.invalid_user_id`). No user identity/credentials were requested from the tester or inserted into chat.

Required manual checks:
- Incognito with no prior Access session must see a login/denial **before** obtaining protected API JSON.
- Signed-in identity not in the allowed selector must be **denied**.
- Authorized tester must receive protected API health only after authentication.
- Do not share credentials, Access cookies, identity tokens or secret values in test reports.

## 3. Disposable D1 recovery drill — PASS

Isolated test database created: `asc-stage1666-recovery-drill-20261115`.
- It was not a Worker binding and had **no application, personal or Production records**.
- Database identity verified from D1 metadata and had `version: production` storage subsystem.
- Created a synthetic `recovery_probe(id,label,value)` table containing three rows:
  `(1,alpha,11)`, `(2,beta,22)`, `(3,gamma,33)`.
- Queried current D1 Time Travel **bookmark** before mutation.
- Deliberately mutated fixture `id=2` from 22 to 999 and inserted a fourth test row `(4,transient,444)`.
- Called the Cloudflare **D1 Time Travel Restore API** on the disposable test database, using that exact saved bookmark.
- Verified API restore succeeded and the complete ordered rowset matched the original three rows byte-for-byte as JSON; the added fourth row was gone, original value 22 restored.

**Result: PASS — actual in-place Time Travel rollback in an isolated throwaway DB.**

This is **not** a successful restore of Production `arcscriptcenter-db`, not a test of an independent database export/clone and not proof of Production application-level recovery.

Reference: https://developers.cloudflare.com/d1/reference/time-travel/

## 4. Release gates

| Gate | Status |
|---|---|
| Stage16.64 Sandbox contract tests | PASS — 19/19 confirmed by user |
| Stage16.65 Sandbox synthetic data cleanup | PASS |
| Stage16.66 Turnstile widget inventory | PASS — no real widget exists; prerelease test BLOCKED |
| Stage16.66 Access policy configuration inspection | PASS — one email-based allow policy |
| Access denial smoke tests (unauthenticated and unauthorized identity) | PENDING |
| Stage16.66 isolated synthetic D1 Time Travel recovery drill | PASS |
| Real-key Turnstile server-side validation and fail-closed checks | PENDING |
| Independent, restorable **Production** backup certification | PENDING |
| Browser/Arcsen end-to-end acceptance | PENDING |
| Authorized Production release decision | NO-GO |

## 5. Security & isolation statement

No Production Worker deploy, Production/Staging DB queries that mutate data, secret disclosure, cloud identity changes or GitHub `main` modifications were performed. The backup drill performed **in-place restore only on the newly created, independent test database**.

## 6. Follow-on work

- Authorize provisioning of a dedicated real-key Turnstile widget in the pre-release account/domain, with secrets stored by the user through Cloudflare.
- Run manual Access incognito/unauthorized identity checks.
- Independently export and restore **a controlled backup** into an isolated test environment, with schema and record integrity verification, before considering a Production release. Do not restore the live Production D1 database as a rehearsal.
