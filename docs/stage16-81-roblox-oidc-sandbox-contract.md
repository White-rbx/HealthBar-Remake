# ArcScriptCenter — Stage 16.81: Roblox OIDC Account Verification

Date: 2026-11-17 (Asia/Bangkok)
State: **Offline sandbox code only. Not deployed, not activated, no real OAuth app registration.**
Base: Stage 16.80 verified Violation History contract and Stage 16.79 user-tested Roblox UI.

## Roblox's official eligibility requirements

Roblox documentation states:
- Account owners age 13+ can authorize OAuth applications.
- OAuth application developers **must be ID-verified** to register/publish an OAuth application.
- OAuth supports Authorization Code + PKCE; `openid` is sufficient for an ID token with Roblox `sub`.
- Do not work around ID verification, register under someone else's identity without legitimate permission, reuse another application's credentials, or automate Roblox's verification process.

Official references:
- https://create.roblox.com/docs/cloud/auth/oauth2-overview
- https://create.roblox.com/docs/cloud/auth/oauth2-reference
- https://create.roblox.com/docs/cloud/auth/oauth2-develop
- https://developers.cloudflare.com/workers/runtime-apis/web-crypto/

## Components built in this branch

- `sandbox/stage16-81-roblox-oidc-sandbox.mjs`: side-effect-free sandbox module
- `sandbox/stage16-81-roblox-oidc-sandbox.test.mjs`: offline negative and integration tests using disposable ES256 keys
- `.github/workflows/stage16-81-roblox-oidc-offline.yml`: GitHub Actions test only (not deployment)

The sandbox module:
1. Generates random `state`, `nonce`, PKCE `code_verifier` and S256 challenge on the server.
2. Uses a short-lived, `HttpOnly; Secure; SameSite=Lax`, host-scoped correlation cookie.
3. Requires a server-held, **atomically consumed** single-use OAuth transaction and a matching callback cookie.
4. Accepts a token only after ES256 signature verification using pinned Roblox JWKS endpoint and validation of `iss`, `aud`, `nonce`, `sub`, `exp`, `iat` and `nbf`. Multi-audience tokens require `azp` to equal the client ID.
5. Issues a random opaque session cookie for 15 minutes; server stores only a hash of the cookie and its verified subject, **not access/refresh/ID tokens**.
6. Provides `resolveVerifiedPrincipal(request)` for Stage 16.80 and `logout(request)` that **revokes** the corresponding server-side session as well as clearing the browser cookie.

## Security boundaries

**NOT an active API.** The service constructor accepts server-side adapters for:
- `pendingStore.put`, `pendingStore.take` (the latter MUST be atomic)
- `sessionStore.put`, `sessionStore.get`, `sessionStore.delete`
- `exchangeCode` that must talk only to the official Roblox token endpoint with configured credentials kept in protected Worker secrets (never the client)
- `getRobloxJwks` that must fetch only the exact pinned Roblox JWKS URI and perform bounded caching/refresh.

These adapters are not yet implemented/deployed. Current automated tests use isolated in-memory fakes only. Do not use memory adapters in a distributed deployed Worker.

The browser session is HttpOnly and **cannot be handed to a Luau executor**. This is intentional. A future mobile-friendly, one-time account-link process needs a separate, time-limited, server-bound linking step; never send the OAuth code, ID token, access token, refresh token or session cookie into Luau, and do not rely on client `LocalPlayer.UserId` for evidence.

The authenticated history remains gated by a session-derived subject from Roblox `sub`. No `claimed_user_id`, `userId` query parameter, unsigned headers, username or client `identityVerified` is trusted.

## Review and release gates

1. Owner obtains OAuth app legitimately from Roblox under official eligibility and configures exact HTTPS redirect URI and minimum scope `openid`.
2. Server-only secret, state store with atomic take, session store with revocation/expiry and pinned JWKS adapter implemented and audited.
3. Host-scoped CSRF/cookie and callback origin/cross-site behavior verified, including state expiry, replay, mismatched browser, nonce, JWKS key rotation, token revocation and race tests.
4. Add a dedicated Sandbox Worker and isolated staging storage. Never reuse production secrets or state/database.
5. Build account-linking grant that cannot be redeemed by an unrelated Luau client or leaked via copied URL; sensitive data remains server side.
6. Wire the browser-authenticated subject into Stage 16.80 history with server-owned violation linkage, preserving Review/Approved/Denied/History and layout orders (Blue0, Orange1, Red2, Green3).
7. Make the actual Appeal submission endpoint atomically recheck status, enforce Approved no-retry, and log public moderation history.
8. Full security/Roblox mobile E2E, explicit owner review, then discuss Production separately.

## Cloudflare status

During Stage 16.81, NO changes were made to Cloudflare Workers, D1, KV, secrets or production. GitHub branch + Actions only.

**Production NO-GO; OAuth app/session integration NOT ready; verified Violation UI intentionally remains hidden.**
