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

## Stage 7 rollout and mobile acceptance — 2026-11-28

The sections above record the original review-only candidate. The owner subsequently authorized the five Gateway operations below for isolated STAGING. The protected ESLogin website keeps its existing single-email Access policy and remains the only interface for Passkeys and pairing approvals.

| Component | Verified configuration |
| --- | --- |
| Gateway | `arcscriptcenter-eslogin-pairing-qa.kogpasan14.workers.dev`, exactly five POST routes under `/api/v1/accounts/` |
| Approved routes | `pair/start`, `pair/poll`, `session`, `heartbeat`, `logout` |
| D1 | `04715765-050f-4e26-b4f6-6101bba9dc97`; additive `asc_qa_pair_gateway_budget` table; foreign key check passed |
| Rate limits | Separate edge namespace `71128` plus atomic global per-route fixed-minute and daily D1 counters |
| Credential scope | 5-minute approval, one successful claim, 4-hour maximum in-memory Loader session; domain-separated digests keep it separate from protected-site credentials |
| Gateway response | Minimal account ID, display name, and moderation status after a valid Gateway bearer |
| Locked rollback version | `3a30a139-ff20-4e45-9e5a-ad2d230c326b` |
| Protected site | `arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev`; Access and browser routes unchanged |

The opt-in Loader uses the new Gateway for server checks and the protected website for user approval. Remember is disabled. Rejoin requires a new pairing, even if the browser already has a valid Passkey session. The Gateway cannot serve private account cases, browser authentication, or account settings. Tests exercising fail-closed, SQLite, Luau VM, and shared-D1 workerd run in the consolidated CI workflow.

### Authorized Roblox Studio place

Use a private STAGING place the project owner controls. Turn on **Allow HTTP Requests** in Experience Settings → Security and install the following scripts from this branch.

| Studio location | Source and instance type |
| --- | --- |
| ServerScriptService | `ASCAccountClientPreview` ModuleScript from `sandbox/ASCAccountClientPreview.lua` and `ASCAccountStudioBridge` Script from `sandbox/ASCAccountStudioBridge.server.lua` |
| ReplicatedStorage | `ESLogin` ModuleScript from `sandbox/ESLogin.lua` |
| StarterPlayerScripts | `ASCAccountStudioQA` LocalScript from `sandbox/ASCAccountStudioQA.client.lua`. Add its child BindableEvents `VerifiedLoaderSession` and `SignOut`. |

The server creates the dedicated RemoteFunction and uses Roblox `HttpService:RequestAsync`; the client receives only the short-lived display code and verified status. Connect the place's Studio-compatible ExperienceSettings Loader to the LocalScript's `VerifiedLoaderSession` event. Continue on `normal`, continue with feature restrictions applied on `restricted_mode`, and close protected UI on `false`. The owner-controlled Studio place and its Loader code are required to verify this handoff on a device.

### Android acceptance

1. Join the private staging place and tap **Login** in the original ESLogin UI. In Android Chrome, use the identity already admitted by Access, sign in using a Passkey, then approve the code from this Roblox instance.
2. Return to Roblox. Confirm pairing completes, the gate returns `normal`, and the Studio-compatible Loader opens. Confirm **Remember** is disabled. Leave and rejoin, then confirm a fresh pairing is required.
3. Sign out using the place's **Sign Out** control wired to the `SignOut` event. Confirm protected UI closes and the old session is rejected. Repeat with an X close before approving, and with a code left unapproved for five minutes. Neither should continue to Loader.
4. Use a synthetic restricted account and verify restricted UI, then a synthetic banned account and verify the Loader stays closed. Test airplane mode during a check and verify Loader policy does not report a verified session.
5. Record build, device, and outcome. Avoid recording the pairing code or any authentication credential. Record separately whether the Studio-compatible Loader continued and whether restriction behavior passed.

**Full Stage 7 acceptance remains pending a real Roblox Mobile run in the authorized experience.**

### Deployed evidence

- Gateway code commit `33c92a314136cace915c93f636ea6d3b4eb1194c`; deployment `448bdee9-c8f0-4100-bd0d-bc81bacb9ac7` runs version 3 `e5024868-9acb-4c61-a06f-b987ba5ac0dd` at 100%. Version URLs are disabled.
- Live protected-site routes for approval, Passkey login options and private history returned the expected Cloudflare Access challenge for anonymous requests. The protected site deployment remains `2ce77fd5-f88c-48a9-b574-7b1e6a3a57b0`, with the original Account QA still at Version 10.
- Live public Gateway returned a synthetic pairing in the pending state. A nonexistent pairing returned HTTP 410. Session, heartbeat and logout with no bearer returned 401. Disallowed paths and OPTIONS returned 404. Cross-origin requests were rejected and the Gateway issued no cookies. The live D1 quota table recorded the start and polls; foreign-key check was clean. The synthetic pairing expires automatically.
- Local regressions passed 36/36, and Luau VM passed 19/19. The shared-D1 workerd test ran the protected Worker approval handler and the Gateway claim. Concurrent claims returned one success and one HTTP 410. The D1 budget admitted 20 of 22 concurrent start requests. The test also confirmed expiry, restricted-account status, revocation and credential separation. The local fixture uses a synthetic browser session.
- GitHub Actions passed [Consolidated QA](https://github.com/White-rbx/HealthBar-Remake/actions/runs/46119094452) and [Verified History QA](https://github.com/White-rbx/HealthBar-Remake/actions/runs/46119094481) for the deployed code.
- Rollback the independent Gateway to its locked version above, then disable its `workers.dev` subdomain if necessary. Keep Version URLs disabled. Keep the additive D1 table, and leave the protected site deployment and Access policy in place.

**GO for the private-place acceptance test. Stage 7 remains open.** A real Android pairing approved on the protected website and followed by verified ExperienceSettings Loader continuation has not yet been witnessed.

### Owner architecture clarification — 2026-11-28

The owner-provided flow diagram distinguishes the **ArcScriptCenter/Cloudflare server** from a Roblox experience server. ESLogin and the Loader's presentation are per-user client UI; account creation, human verification, authentication, pairing approval, session validity, and account authorization are Cloudflare responsibilities. The Cloudflare Gateway is a transport-independent backend with no dependency on a particular Roblox place or game server. The Studio bridge is an optional, owner-authorized QA adapter, not a dependency of the Cloudflare service and not a change to the intended UI architecture.

The supported Roblox runtime still requires an experience server for outbound external HTTP. Do not bypass that platform restriction or treat unsupported runtimes as verified deployment targets. For any other authorized application runtime, separately assess its supported HTTPS transport and credential isolation. A local Loader UI gate is not a security boundary: privileged backend actions must independently authenticate and authorize each request.

Interpret an unauthenticated/expired session as **sign-in required**, not proof that the person has no account. Existing users sign in on the protected website; new users register and complete human verification there. The current Stage 7 protocol has the application initiate a short-lived pairing and the authenticated website approve it, not the reverse. Keep password hashes and WebAuthn public credential material server-side; never store Passkey private keys or expose recovery secrets in the Loader. Keep the five-route Gateway scope unchanged.

Read-only control-plane recheck: Gateway version `e5024868-9acb-4c61-a06f-b987ba5ac0dd` at 100%, workers.dev enabled and preview URLs disabled; protected website version `d615ff9c-7631-499e-9031-b1b2ca2b96d5`; Production API version `298de84d-418c-489c-b133-c549c785f66e`. No deployment or database changes in this architecture clarification. Mobile acceptance still requires the real authorized place and a Studio-compatible Loader; a passing backend test is not proof of a supported mobile integration.

### Supported Loader entry and protected MyAccount

Place `ESLogin` and `ASCAccountLoaderGate` ModuleScripts in ReplicatedStorage. The authorized place's existing client Loader calls the gate with `start(profile, signOut)`, `update(profile)`, and `stop(reason)`. Apply the initial account policy before mounting UI and tear it down on session loss. The Studio QA LocalScript can still drive the existing two BindableEvents for an independent test of the same gate.

The experience server Script uses Roblox HttpService and holds the pairing secret and Loader bearer in memory. It exposes a server-only `ASCAccountLoaderAuthorization` BindableFunction for the host's server handlers. Status is available after a verified heartbeat for up to 28 seconds and is cleared on logout, cancellation or a failed heartbeat. Replicated state carries neither credential nor moderation status.

The protected MyAccount Worker provides profile edits, account-owned Feedback and Appeal, active sessions and moderator review. The additive `migrations/asc_passkey_account_actions_ISOLATED_QA_ONLY.sql` is for the existing isolated ESLogin D1. Session revocation and allowlisted moderator actions use a fresh, single-use WebAuthn assertion bound to the current web session and the requested action. Moderator access remains off until the account's verified ArcID is explicitly configured in `ACCOUNT_MODERATOR_IDS`. Legacy receipt-based cases retain their ownership rules. The Gateway continues to expose only the approved five operations.
