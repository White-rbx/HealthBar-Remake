# ArcScriptCenter Account staging QA

The account preview is opt-in through `sandbox/ASCAccountLoaderPreview.lua`. It preserves the existing ESLogin layout. Login and registration take place on the account website. ESLogin displays a five-minute one-use pairing code. The website confirms the link after authentication, including 2SV when enabled. The Executor polls using a separate random secret, then validates the resulting scoped session with the Worker before opening SetUp. Roblox Studio can reuse ESLogin with an injected transport and PlayerGui parent. A Roblox Studio account transport is outside this preview.

Browsing the account site uses an HttpOnly, Secure, SameSite=Strict cookie. The Loader credential grants only authenticated Loader operations, including the owner's cases. It cannot change account security or profile settings. Remember stores that revocable credential and its expiry in `ArcScriptCenter/Account.json`. Executor file storage is readable by the local host and Executor; use session-only mode on shared or untrusted devices. The Loader credential expires in four hours, or 12 hours with Remember. After a logout or expiry in an already running Loader, rejoin and launch the preview again to initialize new UI handlers. With Remember off, pair again after rejoining. The website's Active Sessions setting can revoke an individual session.

Active presence is recorded with the account ID and a heartbeat every 30 seconds from the running Loader. An account counts once across sessions and drops from the internal count 90 seconds after its last heartbeat. Public online visibility is separate. No hardware identifiers or client-asserted Roblox identity are used. Profile nicknames are visible to their owner in this preview. If a future feature shares them with other Roblox players, it must add Roblox text filtering before display. For a configured image or banner, the Worker checks for an available public Roblox thumbnail. The native preview uses the original logo and the selected banner color as fallbacks.

## Deploy to isolated QA

1. Allocate a new empty D1 database dedicated to the account preview. Apply only `migrations/asc_unified_account_ISOLATED_QA_ONLY.sql` to that database.
2. Use a Worker named `arcscriptcenter-account-qa` at `https://arcscriptcenter-account-qa.kogpasan14.workers.dev`. Its module entry is `sandbox/asc-account/worker.mjs`, with `nodejs_compat` and compatibility date `2026-08-06` (or later). Bind the new D1 as `ACCOUNT_DB` and set `ASC_ACCOUNT_MODE=isolated-qa`. Bind `ACCOUNT_RATE` to a dedicated Workers rate-limit namespace. A suggested starting profile is 12 requests per 60 seconds per key. Rate keys include operation, IP, account or normalized username, as applicable.
3. Set `ACCOUNT_TURNSTILE_SITE_KEY` to the public key for this QA hostname. Provision the corresponding `ACCOUNT_TURNSTILE_SECRET` as a Worker secret and configure the registration widget for the `asc_register` action. Set `ACCOUNT_TOTP_KEY` as a Worker secret containing 32 cryptographically generated random bytes encoded as 64 hex characters. Use a Workers plan and CPU configuration that can run the configured scrypt cost, then check login and password rotation latency against the deployed Worker.
4. To exercise account moderation, register a synthetic operator, enable TOTP, and populate `ACCOUNT_MODERATOR_IDS` with the account's server UUID. The moderation API requires an approved Account ID, a current website session, a password and a second factor. The existing Banned Check Center still operates against its existing store. A dashboard view for account moderation can follow once this preview is accepted.
5. Run synthetic Mobile and Cloudflare HTTP smoke tests before serving any non-test accounts. In Roblox, cover pairing, verification-required, Remember and rejoin, no Violation history, Restricted Mode chat/tools, an approved Appeal, and a Banned account. Banned accounts can read and appeal their own cases on the website. Check logout, expiry, unsupported transport, and mobile portrait and landscape.

Legacy BANNEDTOKEN, USERCASETOKEN and historical records stay on their existing routes and tables. The server linking helper requires a verified external identity already associated with the ArcScriptCenter Account ID and a trusted existing case. No public linking route is enabled. Leave historical linking inactive until a trusted Roblox ownership provider and a review path for legacy records are configured.

To roll back the preview, disable the Account QA Worker and stop using the opt-in Loader entry. Keep the additive D1 tables for investigation. If test credentials need invalidation, revoke them in the isolated store. Git rollback is a revert of the account change on the existing branch. Existing Loader entrypoints, Cloudflare Workers and historical case tables are independent of this deployment.

## Verified QA blocker — 2026-11-23

Read-only review of the connected Cloudflare account confirms that the isolated `arcscriptcenter-account-qa` Worker and its dedicated Account D1 are **not yet provisioned**. Ten D1 databases already exist. Prior candidate deployment reported D1 error 7406. None of the inspected QA databases was empty, and some are bound to active QA Workers. **Do not delete, rename, overwrite, repurpose, or attach an existing database to Account QA without separately authorized review and a tested backup/restore plan.** Production and the existing staging DB are expressly out of scope.

The Roblox message `This account is outside the authorized QA test scope.` originates from `sandbox/ExperienceSettings-SetUp-Preview.lua` when the legacy Ban Policy QA client receives `403 target_not_allowed`; it is **not an ArcScriptCenter Account ban**. The account preview entrypoint is `sandbox/ASCAccountLoaderPreview.lua` (mode `account_qa`), but its backend must be deployed before end-to-end mobile sign-in can succeed. Keep the Ban Policy allowlist enforced, and use synthetic authorized test accounts after isolated Account QA is available.

Next unblock sequence: obtain genuinely isolated D1 capacity (plan/capacity increase, or explicitly approved archival of an inspected obsolete QA database only after backup); apply the additive Account QA migration; configure the dedicated Worker and secrets; verify registration, website pairing, 2SV, session, normal/restricted/banned Loader paths, and owner-scoped cases on Roblox Mobile. No bypasses or production mutations.

## QA mobile login entrypoint and Tester — 2026-11-24

The account Login UI is **not** loaded by the default `sandbox/LoaderMainPreview.lua` (which defaults to `public_qa`). `sandbox/ESLogin.lua` is not a standalone entrypoint either: it returns `false` if no account client table was injected. To exercise the Account Login UI, use the explicit opt-in entrypoint:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/ASCAccountLoaderPreview.lua"))()
```

This passes `account_qa` into the staging Loader, which loads `ASCAccountClientPreview.lua`, validates an existing account session and calls `ESLogin.lua` if there is no valid session. The GUI may display even while Account QA backend is offline, but registration, pairing and successful login **cannot** complete until the dedicated Account Worker and D1 are provisioned and deployed. Do not weaken the server-side authentication or enable account access from a claimed Roblox UserId.

The isolated Cloudflare Worker `arcscriptcenter-ban-policy-qa` has its **Ban Policy QA public-status** allowlist variable `BAN_PUBLIC_QA_TEST_IDS` changed from `9777206932` to `8728964745`. This does not grant a private Account Session, unlock Account QA, migrate any cases, or change Production. If the UserId is not in another isolated QA Worker's own configured scope, that separate QA mode still rejects the ID. Check the executor console for `[ES][QA]` and `[ES][AccountQA]` diagnostic messages when the UI does not appear.

## Account QA public provisioning endpoint — 2026-11-24

Cloudflare Worker `arcscriptcenter-account-qa` has been created as a **credential-free, non-authenticating staging holding service**, deploying source `sandbox/asc-account/provisioning-worker.mjs` at `https://arcscriptcenter-account-qa.kogpasan14.workers.dev/`. The Workers.dev subdomain is enabled and Cloudflare's deployment API shows one deployed version receiving 100% of traffic. Direct external HTTP verification from the assistant's environment was unavailable; check on a real browser before declaring the URL end-to-end tested.

The holding page clearly states that registration, password authentication, TOTP, pairing, and API sessions **are not operational**. All `/api/v1/accounts/*` operations return HTTP 503 `account_qa_provisioning`; `GET /health` also reports HTTP 503 and `loginEnabled:false`. No account database or existing Workers are bound or modified, and no user credentials are accepted. The full `sandbox/asc-account/worker.mjs` remains ready for separate secure rollout.

To activate **real** Account QA safely, first obtain isolated D1 capacity or separately approve an existing QA database only after independent backup/recovery review. Then apply `migrations/asc_unified_account_ISOLATED_QA_ONLY.sql` and configure `ACCOUNT_DB`, `ACCOUNT_RATE`, `ASC_ACCOUNT_MODE=isolated-qa`, approved registration hostname / Turnstile site key plus secret, and `ACCOUNT_TOTP_KEY`. Bundle all worker modules and test password hashing capacity before replacing the provisioning Worker. Never enable the credential-collecting registration interface without all required protections and database configuration.

Roblox `sandbox/ESLogin.lua` displays a specific `account_qa_provisioning` notice rather than an ambiguous network error when it receives the holding service's 503 response. The client distinguishes a first-time no-session launch from an expired session. Check GitHub Actions and mobile after each change.

## ESLogin early bootstrap and Close X — 2026-11-24

In the opt-in Account QA Loader, the `ESLogin.lua` source is fetched and compiled by `loadstring()` in the **first Loader bootstrap block**, before the account-session refresh and before SetUp, Loader UI, or Arcsen begin. A previously valid, server-verified Account Session still skips the login dialog; otherwise the `ESLoginGui` is displayed before progressing.

`ESLoginGui.Main.Close` is a red **X** button in the upper-right corner of the original login panel. It lives outside the Holder's `UIListLayout` so the original logo, title, dimensions and animations remain unchanged. Activating X destroys only `ESLoginGui`, marks the login cancelled, and causes the bootstrapping Loader to return **without** running SetUp or loading ExperienceSettings. X is not a Logout or ban bypass.

Pairing checks stop on cancellation, and `ASCAccountClientPreview.lua` rejects a pairing response if the login GUI is closed. Any in-flight session created just as X is pressed is invalidated locally and receives a best-effort remote logout request; remembered JSON is erased even if the logout request fails. This only applies to `account_qa` STAGING, not Production or legacy `public_qa`. The Account QA backend is still in provisioning mode (HTTP 503), so a visible login UI does not mean authentication is operational.

