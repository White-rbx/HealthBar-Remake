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
- `sandbox/asc-account/isolated-pairing-gateway-candidate.test.mjs`: disconnected synthetic D1 tests for disabled gate, only-two-route attack surface, malicious origins, malformed payloads, rate-limit denial, secret storage, unapproved state, single-use issuance, replay, expired approval and revoked web session.
- The existing `sandbox/ASCAccountClientPreview.lua` is **not** routed through this gateway yet. No unreviewed gateway hostname is invented or configured.

## Remaining protocol work before live Stage 7

This candidate **does not** make Loader login work by itself. After `pair/poll`, Roblox still needs to validate its `loader` session and eventually revoke it. The existing `session`, `heartbeat` and `logout` routes are still protected by Cloudflare Access.

A complete client transport would require a design for only those **bearer-authenticated, loader-scoped** APIs in the same isolated security boundary, retaining strict D1 session verification and revocation; case/history/appeal APIs need separate review and must not be exposed accidentally.

Implement the remaining loader-session surface with negative tests and a segregated client `pairOrigin` only after the architecture has been reviewed. Confirm in a real Roblox-supported HTTP environment that a separate staging gateway is reachable without copying browser credentials. For a game owned by the developer, a trusted Roblox game server with owner-stored secrets is an alternative, but it **does not** solve deployment into arbitrary third-party games.

## Release controls

- Do not create a publicly accessible Worker, change the existing restricted Worker Access policy, or enable any Access bypass solely to pass a test.
- Do not deploy a test candidate with in-memory authentication/session storage. Shared isolated D1 must be transactional and rate-limited.
- Never log pairing secrets, Loader bearer sessions, recovery codes, Access cookies, or personal identifiers.
- Keep `arcscriptcenter-eslogin-edge-qa` on its last verified live version and original Account QA / Production unchanged. PR #16 stays Draft.
- Stage 6: Android registration and login observed PASS; real Backup and Recovery not complete.
- Stage 7: authenticated website works; universal Loader transport remains BLOCKED until session API and reviewed gateway deployment are completed.
