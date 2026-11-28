# ESLogin Stage 7 — isolated pairing-gateway candidate (2026-11-28)

**Status: OFFLINE SOURCE + CI ONLY. NOT DEPLOYED. NOT PUBLIC. NOT AN ACTIVE ROBLOX LOGIN.**

## Why this candidate exists

The protected ESLogin browser works on Android Chrome with an approved Cloudflare Access identity. A separate Roblox Luau HTTPS client cannot borrow that browser's Access authentication. A direct call to the protected account Worker therefore fails at the Access layer before `pair/start` can run.

No browser Cloudflare Access cookie, service token, WebAuthn key, recovery code or session credential will be placed in a Luau executor, an untrusted Roblox client, or GitHub. A Roblox client UserId is not a verified ArcScriptCenter identity.

For a universal cross-experience integration, evaluate a **separately routed, least-privilege gateway**. A separate public gateway is a **new attack surface**, not covered by the protected website's email-only Access policy. Its creation and any public routing require a separate owner authorization and security review. No Cloudflare configuration changes were made.

## Source and offline test

- `sandbox/asc-account/isolated-pairing-gateway-candidate.mjs`
  - No default Worker export, no live route and no automatic deployment.
  - Requires exact configured HTTPS Origin and an explicit `ASC_PAIR_GATEWAY_MODE=isolated-qa`, `ASC_PAIR_GATEWAY_LAUNCH_STATE=explicit-test-enabled`, isolated `PAIR_DB` and `PAIR_RATE`. Missing controls fail closed with 503.
  - Accepts only bounded JSON `POST /api/v1/accounts/pair/start` and `POST /api/v1/accounts/pair/poll`.
  - Rejects browser Origins, cookies, Authorization headers, Access assertions, queries, other routes and unsafe body fields.
  - Uses 48-bit random display code + independent 256-bit secret; stores only SHA-256 of the secret in D1. Access-protected browser must explicitly approve the one-time code in the existing account application.
  - Uses the same 5-minute expiry and D1 conditional, atomic session claim as the protected Account Worker; only a valid unrevoked web approval may yield a `loader`-scoped session.
  - Public route rate limits remain mandatory. No account password, recovery code, passkey material or personal IP identity is stored.
- `sandbox/asc-account/isolated-loader-gateway-candidate.mjs`: **undeployed** composition of the pairing-only gateway with three additional loader-scoped operations: `session`, `heartbeat` and `logout`. Each requires an opaque 256-bit `Bearer` token returned only once to the holder of the approved pairing secret. The server hashes the token and checks `scope='loader'`, session revocation, expiry, and account state in the isolated D1. `heartbeat` respects banned accounts, `logout` revokes the D1 session. No personal UserId claim or browser cookie is accepted.
- `sandbox/asc-account/isolated-pairing-gateway-candidate.test.mjs`: disconnected synthetic D1 tests for disabled gates, only-five-route composite scope (two anonymous + three bearer-authenticated), malicious origins, malformed payloads, rate-limit denial, secret storage, unapproved state, single-use issuance, replay, expired approval, revoked web session, Loader profile validation, banned heartbeat and logout revocation.
- The existing `sandbox/ASCAccountClientPreview.lua` is **not** routed through this gateway yet. No unreviewed gateway hostname is invented or configured.

## Remaining protocol work before live Stage 7

**The offline Gateway protocol is now implemented as a candidate, but it does not make Roblox Login live.** No separate Gateway Worker has been created/deployed or made public, and the Luau client still targets the Access-protected website. Code in this branch alone does not open Cloudflare's Access layer.

Before actual Roblox use: audit the composite five-route transport for security, provision an isolated Cloudflare Worker with only the required D1/rate bindings, decide and explicitly authorize its Internet exposure, verify rate-limit behavior and Access separation, and then change the opt-in Roblox client to send ONLY the approved five operations to the audited Gateway origin. Do not forward `history`, `feedback`, `appeal`, `profile`, `security/*` or browser Passkey routes through it; those require separate identity/data-access review.

Confirm in a real Roblox-supported HTTP environment that a separately approved staging Gateway is reachable without copying browser credentials. For a game owned by the developer, a trusted Roblox game server with owner-stored secrets is an alternative, but it **does not** solve deployment into arbitrary third-party games.

## Release controls

- Do not create a publicly accessible Worker, change the existing restricted Worker Access policy, or enable any Access bypass solely to pass a test.
- Do not deploy a test candidate with in-memory authentication/session storage. Shared isolated D1 must be transactional and rate-limited.
- Never log pairing secrets, Loader bearer sessions, recovery codes, Access cookies, or personal identifiers.
- Keep `arcscriptcenter-eslogin-edge-qa` on its last verified live version and original Account QA / Production unchanged. PR #16 stays Draft.
- Stage 6: Android registration and login observed PASS; real Backup and Recovery not complete.
- Stage 7: authenticated website works; a five-route Loader transport exists only as offline candidate and is BLOCKED pending reviewed Gateway deployment, Access separation and real Roblox Mobile tests.
