# ESLogin / ArcScriptCenter — isolated QA D1 capacity recovered (2026-11-25)

**STAGING ONLY. No real accounts, sessions, Passkeys, Production changes or QA traffic rollout.**

## Conditional owner approval and deletion

The owner authorized retiring `asc-feedback-release-qa-20261117` **only if no application data remained**. Before deletion the following safeguards were completed:

- Exactly **7 accessible application tables**, all with **0 rows**, were rechecked immediately before deletion. The deletion operation refused to run if any count was nonzero or unverified.
- `PRAGMA foreign_key_check` found zero violations.
- All **13 current Worker script configurations** and all **3 Pages project deployment configurations** were inspected for direct D1 bindings; **none pointed to the target ID**.
- The Worker Preview inventory contained no Preview known to reference the retired D1. Historical QA documentation `docs/feedback-isolated-worker-runtime-qa-pass-20261117.md` confirms its disposable rate-limit Worker was deleted and its 7 test rows cleared.
- Cloudflare's reserved `_cf_KV` table was not queried (D1 returns `SQLITE_AUTH`), and it does **not** represent a user application table; Cloudflare documents it as internal storage metadata: https://developers.cloudflare.com/d1/best-practices/import-export-data/
- A **schema-only recovery artifact** containing all **21 user-defined SQL objects**, without any data rows or secrets, was archived in `docs/asc-feedback-release-qa-20261117-schema-archive-20261125.sql`, commit `dfd0a5cf9dbeb64a46c27433100ac997d6049081`. A D1 export task completed, but its signed R2 artifact could not be downloaded from the authorized connector environment (HTTP 403). Do not claim a verified full backup file exists.
- The former D1 ID was `fb828e2b-b10b-41ac-95bd-3873ff3cccd5`. Cloudflare DELETE succeeded and subsequent GET D1 inventory confirmed it is no longer listed.

## Replacement D1 (synthetic only)

| Field | Result |
| --- | --- |
| Name | `asc-eslogin-passkey-isolated-qa-20261125` |
| ID | `04715765-050f-4e26-b4f6-6101bba9dc97` |
| Location hint | `APAC` |
| D1 count after replacement | **10/10** |
| Source migrations | `asc_unified_account_ISOLATED_QA_ONLY.sql`, `asc_passkey_ISOLATED_QA_ONLY.sql`, `asc_passkey_backup_ISOLATED_QA_ONLY.sql`, `asc_passkey_recovery_ISOLATED_QA_ONLY.sql` |
| Applied SQL statements | **18/18 successful** |
| Account & Passkey application tables | **11** |
| App record counts | **0 in all 11 tables** |
| Foreign key violations | **0** |
| Assigned QA Worker bindings | `ACCOUNT_DB` → isolated D1 `04715765-050f-4e26-b4f6-6101bba9dc97`; `ACCOUNT_RATE` → namespace `20261125`, 40 requests / 60 seconds |

The 11 new tables are `asc_accounts`, `asc_account_sessions`, `asc_account_recovery`, `asc_account_pairings`, `asc_account_cases`, `asc_account_verified_links`, `asc_account_passkeys`, `asc_account_passkey_flows`, `asc_account_passkey_backup_flows`, `asc_account_passkey_recovery_codes`, and `asc_account_passkey_recovery_flows`. No synthetic or real account was created and no credentials were stored.

The GitHub `verifyPrivatePreviewPlan` gate now requires exactly `PIN.previewDb` matching this new ID, and rejects an arbitrary valid UUID or the pre-existing Account QA D1 ID. This guard does not itself authorize activating login.

## Isolation preserved

- Existing deployed Account QA Worker **Version 10 remains at 100%**.
- Uploaded Passkey **Version 11 remains undeployed at 0%**.
- `previews_enabled=false` on the existing Account QA Worker.
- The independently routed `arcscriptcenter-eslogin-edge-qa` Worker remains **Access DENY Everyone**, with **zero resource bindings** and static Provisioning responses; prior live unauthenticated GET and POST gave Cloudflare Access 302 challenges.
- Original `eslogin` Preview remains non-routable and Access DENY Everyone.
- GitHub PR #16 stays **Draft**.

## Next no-go gates

Before connecting the new synthetic D1 to an authenticated Worker, review (1) isolated Worker and fixed exact HTTPS WebAuthn Origin/RP ID; (2) Access policy restricted to synthetic testers and a fresh anonymous-edge denial test; (3) separate QA-only Turnstile keys with matching site hostname and `asc_register` / `asc_recover` action checks; (4) isolated rate limiting and synthetic-only secrets; (5) staging Pairing + Session + rejoin/logout + Android acceptance. Never enable Version URLs on the original QA Worker as a workaround, reuse the old Account QA D1, or merge PR #16 without explicit review.

**Current status: isolated D1 capacity and schema PASSED; live authenticated ESLogin integration NOT YET COMPLETE.**

## Follow-up: Isolated QA Worker bindings (November 25, 2026)

The separately routed `arcscriptcenter-eslogin-edge-qa` Worker was configured with **only** these two bindings, then read back using the Cloudflare API:

- `ACCOUNT_DB`: D1 ID `04715765-050f-4e26-b4f6-6101bba9dc97` — the new empty, synthetic-only account database, **not** the original Account QA D1.
- `ACCOUNT_RATE`: independent rate-limit namespace `20261125`, limit **40 per 60 seconds**. Cloudflare inventory confirmed this namespace is distinct from those on existing Workers.

Readback confirmed that the separate Worker still has Access app `ea0346cb-02fb-44dc-a5dd-5ada7c60977f` targeting **only** its Worker ID, `DENY Everyone` policy with no exceptions, `options_preflight_bypass=false`, and `previews_enabled=false`. The Worker still runs the static provisioning-only entrypoint; its code does **not** use either binding to issue a credential, initialize a session or access data.

The original Account QA Worker remains Version 10 at 100% traffic; its Passkey Version 11 is **not activated**. All 11 tables in the new D1 still contain **0 rows**.

**Turnstile and secret provision:** an attempt to automate a fresh restricted-domain QA Turnstile widget and store QA-only secret bindings was blocked by tool-level security checks. Read-only verification confirmed the new QA widget was **not created** and no new secret bindings were applied. Do not reuse the original QA or Production Turnstile sitekey/secret. Create a separate managed Turnstile widget for `arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev`, store its secret privately as `ACCOUNT_TURNSTILE_SECRET` and a separately generated 256-bit `ACCOUNT_TOTP_KEY` as a Worker secret, and use the new widget's public sitekey as `ACCOUNT_TURNSTILE_SITE_KEY` **before** any authenticated staging launch. Verify both `asc_register` and `asc_recover` Siteverify action checks.

**Remaining blockers:** restricted synthetic-user Cloudflare Access policy (not Deny Everyone), reviewed exact HTTPS WebAuthn Origin/RP ID for the new Worker, QA-only Turnstile and private secrets, and live Android/Roblox Mobile integration. Never enable real login as a shortcut. Preserve the locked Worker's static Provisioning behavior until the full authentication rollout is explicitly reviewed.

Automated security guards are now in `sandbox/asc-account/eslogin-locked-resources-gate.mjs` and `sandbox/asc-account/eslogin-locked-resources-gate.test.mjs` and are integrated into the PR CI and Private Preview Preflight workflows. These offline tests validate synthetic control-plane snapshots; independently read back Cloudflare configuration before asserting the live state.

## Undeployed Passkey candidate prepared

`sandbox/asc-account/eslogin-isolated-account-candidate.mjs` now provides a **named factory only** to construct the maintained account/Passkey Worker with exact HTTPS Origin `https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev`. It deliberately exports **no default Worker**, has no deployment action, does not change the live provisioning entrypoint, and never derives the expected WebAuthn Origin/RP ID from an inbound request.

The companion `sandbox/asc-account/eslogin-isolated-account-candidate.test.mjs` tests:
- explicit, exact independent HTTPS Origin;
- no account writes or rate limit calls when QA launch flags are missing;
- fail-closed 503 when a synthetic launch flag is present but Turnstile/Secret bindings are still absent;
- 404 for requests on the wrong host or protocol.

Both this candidate test and the exact D1/rate-limit/Access assertions are now in the consolidated GitHub PR CI and offline Private Preview Preflight.

**Next required owner-controlled configuration remains QA-specific Turnstile and secrets.** The connected tool's security checks blocked automatic creation/storage; no widget was created. No workaround to that tool boundary was used. The dedicated QA Worker remains denied by Access at the edge and no live account ceremonies are enabled.

## Current independent ESLogin deployment and acceptance

The locked Passkey implementation is deployed to `arcscriptcenter-eslogin-edge-qa` as version 5, `75849a74-a686-4643-89bb-5e2b9c3498ea`, deployment `6a192147-4669-47a3-b077-374ef933138d`. The SHA-256 of the built module and the module read back from Cloudflare is `22aa7c8c7cce579c5190dd6650b3c8eb30cb0db72be03814670b20a56180e6f6`. The rollback target on this Worker is version `3c866847-ff7f-48e5-9e09-2e568f36ad0b`, the provisioning entry with the same five bindings.

| Check | Evidence |
| --- | --- |
| Access | One self-hosted app targeting only the independent Worker, DENY Everyone, zero exceptions, OPTIONS bypass disabled. Anonymous GET and POST returned 302 to the tenant's Access login. No tester has been added. |
| Turnstile | Dedicated managed widget, no pre-clearance, exact independent hostname. The Worker has all three QA secret bindings. Siteverify hostname and action checks for registration and recovery run in local fixtures. Real challenge redemption needs an authorized tester. |
| Worker | Exactly the dedicated D1, 40/60s limiter and three secret bindings. No launch flags. The deployed entry permits only an explicit Passkey launch, and otherwise returns provisioning. |
| Storage | The 11 synthetic account tables remain empty after deployment. Foreign-key check returned zero violations. |
| Original Account QA | V10 at 100%, V11 undeployed, Version URLs disabled. |
| Loader | The opt-in account client now pins both the pairing website and HTTP API to the independent origin. Remember credentials from the old origin or a file with no issuer require fresh pairing. |
| Offline QA | Luau VM covers X, timeout, cancellation, restricted policy, Remember/rejoin and offline logout. The isolated bundle ran in workerd with local D1 and both Siteverify action fixtures. Chromium exercised the real website JavaScript with two virtual authenticators, registration, sign-in using the backup, recovery, pairing, restricted session, expiry, logout and revocation. |
| Live acceptance | **BLOCKED**. No admitted Edge tester, live Turnstile redemption, live pairing or real Android/Roblox run. |

For a later tester window, owner approval must name each synthetic identity and authorize the Access policy change. Scope the Allow rule to those exact identities on the existing independent app, with default deny, no path bypass, no wildcard domain and no Everyone allow. Recheck both the anonymous challenge and positive tester admission before enabling authentication. The browser and the Roblox HTTP client are independent Access clients. Verify an approved short-lived per-tester Access session for the Loader transport before starting pairing. Never distribute a common Access credential or copy the website's authentication cookie into a Roblox script.

On Android, use the approved synthetic identity on the protected website, enroll a device passkey and backup, approve the one-time code from ESLogin, and verify Loader continuation. Rejoin with Remember on and off, check the restricted account, close a pending login with X, sign out, then verify the server rejects the previous session. Record only outcome, build and device. Do not capture pairing codes, recovery codes, authentication cookies or session files.

**Decision: NO-GO for STAGING closeout until the protected Edge and device flow succeeds.**
