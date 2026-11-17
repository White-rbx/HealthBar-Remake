# ArcScriptCenter — Stage 16.82: OAuth State, Session and Callback Sandbox

Date: 2026-11-17 (Asia/Bangkok)
Status: **Offline sandbox implementation + QA workflow PASSED. NO Worker or D1 deployment.**
Parent branch: `stage16-81-roblox-oidc-sandbox`

## What this stage actually completes

- Implemented isolated D1 SQL adapter contracts for a 5-minute OAuth authorization transaction and 15-minute browser-only authenticated session.
- OAuth `state` can be redeemed only once with a single SQLite/D1 `DELETE ... RETURNING` query; concurrent redemptions cannot both succeed.
- Session stores only a SHA-256 hash of a randomly generated browser cookie and a server-verified Roblox subject ID. OAuth access, ID and refresh tokens are **not persisted**.
- Strict HTTPS-origin browser router:
  - `GET /auth/start` redirects to the official Roblox authorization endpoint.
  - `GET /oauth/callback` checks exact state/code parameters, receives the server-validated OIDC identity and redirects 303 without exposing the authorization code.
  - `GET /auth/session` returns minimal browser-only status.
  - `POST /auth/logout` enforces Origin/Fetch-Site checks, deletes the server-side session, and clears the browser cookie.
  - `GET /auth/connected` displays only a static success message.
- All browser responses avoid credentialed CORS, disable caching and referrers and deny iframe embedding.
- Added automated test coverage for replay, tampered Client identity, wrong browser correlation cookie, session expiry/revocation, callback errors, logout CSRF, unexpected hosts and open redirects.

## Files on this branch

- `sandbox/stage16-82-d1-oauth-stores.mjs` — D1 adapter, **not connected to a deployed DB**.
- `sandbox/stage16-82-oauth-browser-router.mjs` — browser-only HTTP route adapter, **not mounted**.
- `sandbox/stage16-82-oauth-adapters.test.mjs` — browser/OIDC/D1 simulation tests.
- `migrations/2026-11-17_stage1682_oidc_sandbox_only_DRAFT.sql` — schema for a **new isolated sandbox database only**. Do not run against `arcscriptcenter-db` or `arcscriptcenter-staging`.
- `sandbox/test_stage16_82_sqlite.py` — executes SQL extracted from the actual D1 store source against SQLite, including two competing one-time state consumers on separate connections.
- `.github/workflows/stage16-82-oauth-offline.yml` — GitHub Actions QA, also runs Stage16.81 + Stage16.80 regressions.

## End-to-end browser flow (simulated only)

1. Browser navigates to the exact sandbox `GET /auth/start` URL.
2. Worker creates random PKCE verifier/challenge, state, nonce and browser-correlation cookie; atomically stores state with a short expiry.
3. Browser is sent to Roblox. Roblox authorizes the account and redirects with an authorization code.
4. Worker matches the correlation cookie, atomically consumes state, exchanges code using a **server secret** and verifies Roblox-signed OIDC ID token.
5. Worker issues an HttpOnly Secure SameSite=Lax browser cookie. D1 stores only a hash and verified subject. No account identity is accepted from Luau.
6. A browser can check its own session via same-origin `/auth/session`; logout deletes the D1 session so the cookie cannot be used again.

**Steps 3–5 are represented by mocked Roblox responses and disposable ES256 test keys in the automated tests. Real OAuth credentials, live code exchange and official JWKS fetch are not active.**

## Release blockers — STILL NOT DONE

1. Owner obtains a **legitimate, eligible Roblox OAuth 2.0 application** and completes any Roblox ID-verification requirements; no workaround or proxy identity.
2. Server-only production-grade adapters for Roblox token exchange and pinned official JWKS fetching, secret storage and key rotation.
3. Create a **separate sandbox Worker and separate sandbox D1 binding** only after confirming resource names, isolation, abuse controls and log redaction. Never bind this test router to the existing Production database.
4. Add rate limiting, session/pending-state quota enforcement, operational expiry cleanup and monitoring without logging authorization codes, cookie values or ID tokens.
5. Complete security tests under the actual Cloudflare Workers D1 runtime (GitHub/SQLite is not an official D1 deployment test).
6. Stage16.83 must bridge authenticated Roblox browser identity into Arcsen Mobile **without sharing OAuth tokens, browser cookies or private access keys with Luau**, and must not let another user's client claim the linked subject.
7. Server must atomically enforce Appeal states at write time. An `Approved` case can never be appealed again, even if a user modifies Luau.
8. Mobile E2E and owner release review before any Production operation.

## Cloudflare read-only inspection

The existing `arcscriptcenter-api-staging` Worker has a `DB` binding to `arcscriptcenter-staging`. Stage16.82 makes **no changes** to this Worker, its settings, secrets or any D1 database. A new isolated D1 is proposed but not created.

## GitHub CI

Run: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44062656825 — **PASS**
Includes Stage16.82 mocked login + replay tests, SQLite concurrency check, Stage16.81 OIDC verification regression and Stage16.80 Verified History regression.

## References

- https://create.roblox.com/docs/cloud/auth/oauth2-overview
- https://create.roblox.com/docs/cloud/auth/oauth2-reference
- https://developers.cloudflare.com/d1/worker-api/prepared-statements/
- https://developers.cloudflare.com/d1/platform/limits/

**Production NO-GO. No real Roblox login, no live Cloudflare OAuth integration and no user information collected in this stage.**
