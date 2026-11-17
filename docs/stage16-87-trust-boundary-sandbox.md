# ArcScriptCenter — Stage 16.87: Trust Boundary / Restricted Worker Sandbox

**2026-11-17 — DRAFT / code-level and local-workerd tests only.**

## Scope and evidence

- Base branch: `stage16-86-workerd-runtime-qa`.
- Added `sandbox/stage16-87-restricted-gateway.mjs`: a **closed-by-default** gateway factory. It has only one non-privileged sandbox probe route, `POST /__stage1687/rate-probe`, and it is **disabled unless** a local test binding explicitly enables it.
- Requires **two independent, externally verified claims**: `verifySandboxAccess(request)` and `verifyTrustedIngress(request)`. It also requires an injected D1 `checkRateLimit(...)`. Missing callbacks, malformed ingress scopes, denied access, D1 failures and absent test bindings do not allow requests.
- `sandbox/stage16-87-restricted-gateway.test.mjs` tests the trust boundaries, wrong paths/methods, fake identity headers, subrequest clues, invalid network identity, verification errors and denial of all sensitive routes.
- `sandbox/stage16-87-local-worker.mjs` and `sandbox/stage16-86-runtime/stage16-87-local-worker.test.mjs` are **LOCAL ONLY** test fixtures with intentionally fake Access/ingress verifiers and synthetic identity. They are NEVER a substitute for actual Cloudflare Access JWT verification or an authenticated Roblox session.
- `.github/workflows/stage16-87-trust-boundary.yml` runs tests under Miniflare/workerd with D1 and Stage16.83, 16.85, 16.86 regressions.

**No Worker deployed, no OAuth app configured, no real credentials, no access to any Roblox user's private account data, and no Cloudflare D1 migrations or modifications.**

## Important threat model

Cloudflare documents that `CF-Connecting-IP` can differ across same-zone and cross-zone Worker subrequests; in certain same-zone subrequests, an upstream Worker may alter `x-real-ip` and affect the value. Therefore **CF-Connecting-IP, Origin, X-Forwarded-For, X-Real-IP, CF-Worker or a browser-supplied UserId must not independently grant access.**

The Stage16.87 gateway *demands* results from separately injected, verified access and ingress providers and blocks obvious Worker subrequest clues. These checks **do not implement an actual trusted ingress provider**. A real deployment requires infrastructure-controlled ingress policy, verified Cloudflare Access JWT (signature, issuer, audience and expiration), rate limits and server-only secrets. Merely wiring a callback to return `true` is insecure.

Cloudflare documents that secrets belong in Workers Secrets/Secrets Store bindings, not plaintext `vars` or checked-in source files. A live Worker also must be bound exclusively to the isolated D1 rather than Production or existing STAGING DB. The Worker D1 binding does **not** expose its database name for independent proof to the handler; deployment configuration must be reviewed outside the request handler.

## Deliberately unavailable paths

This Stage exposes **NO** authenticated or unauthenticated versions of:
- `/api/v1/violation/history`
- `/api/v1/appeal`, `/api/v1/feedback`
- `/admin`
- `/pair/start`, `/pair/browser/approve`
- `/oauth/callback`

The one probe route returns only `{ok:true,probe:true}` or a generic denial; it never returns a subject ID, Roblox profile, Appeal, moderation decision, browser session cookie, OAuth token or pairing code.

**Browser-accepted pairing is NOT Roblox Luau identity attestation.** It must not authorize private Violation History, Appeal state changes or any admin function.

## Required evidence before a future hosted isolated Worker

1. Legitimately registered Roblox OAuth App where eligible; no bypass of Roblox's developer identity requirements.
2. Server-only, independently verified Roblox OIDC browser sessions and correctly configured Cloudflare Access JWT verification (or another reviewed access control layer).
3. Reviewer-confirmed direct-ingress routing/WAF policy; untrusted Worker subrequests must not be able to impersonate first-party request origin.
4. Secret stored as an encrypted Cloudflare Worker binding, **not in GitHub**.
5. Exact binding review to a completely separate sandbox D1. No Production, existing STAGING or shared admin DB permission.
6. Hosted Worker runtime smoke tests using the supported compatibility date and audit logs without secrets.
7. Abuse/DoS and malicious pairing/phishing tests; every permitted endpoint must have concrete permissions and a server-backed rate limit.
8. Reviewed mobile UX in **English**; no arbitrary Feedback & Appeal account age gates added.
9. Explicit owner authorization before any public Worker deployment, Merge or Production change.

## Current versus next milestones

Stage16.85: Cloudflare D1 REST rate-limiter concurrency verified in isolated Sandbox.
Stage16.86: Local workerd/D1 Worker runtime tests passed, plus English mobile browser demo.
Stage16.87: Trust separation and closed route allowlist **in local code only**; independent verification providers still **not implemented for live Cloudflare**.
Next: Build and independently test a real protected ingress policy + Cloudflare Access JWT adapter against official issuer/audience/JWKS; until that exists, do not enable public endpoints.

## Official docs

- https://developers.cloudflare.com/fundamentals/reference/http-headers/
- https://developers.cloudflare.com/workers/configuration/secrets/
- https://developers.cloudflare.com/workers/runtime-apis/request/
- https://developers.cloudflare.com/workers/testing/
- https://developers.cloudflare.com/d1/worker-api/prepared-statements/

**Production `arcscriptcenter-db` and existing `arcscriptcenter-staging` have not been changed.**
