# ArcScriptCenter — One-Page Production Release Closure

**2026-11-16 · Review only · PRODUCTION NO-GO**

This is the single operational owner handoff. Stop adding new Stage IDs and unnecessary repeated audits. **Owner expressly authorized NEW Production Access and Turnstile configuration on 2026-11-16, and those resources were created. This does NOT authorize Worker deployment, database migration, Cron activation, existing Secret changes or any other Production configuration modification.**

## Owner-approved provisioning — completed (2026-11-16)

- **Cloudflare Access application created:** `ArcScriptCenter Production - Admin Push Paths`, ID `90db170a-cb3d-493f-9396-aef470117795`, on the strictly scoped `arcscriptcenter-api.kogpasan14.workers.dev/api/v1/admin/push/*` only. Not a blanket Worker-level Access rule.
- **Reusable Access allow policy created:** `ArcScriptCenter Production - Owner Admin Push Only`, ID `08da7b2e-1a56-453e-930f-471504755d75`, exact authenticated Cloudflare owner email selector only, single policy, eight-hour session. No owner email is included in this repository.
- **Dedicated real Turnstile widget created:** `ArcScriptCenter Production - Real Turnstile`, `managed` mode, `no_clearance`; exactly one hostname: `arcscriptcenter-api.kogpasan14.workers.dev`. Its **public sitekey** is `0x4AAAAAAGDcKTGgG4P3F1I4`.
- **Private widget secret remains only in Cloudflare:** the API verified that it is available; it was never copied to GitHub, chat, or Worker settings.
- **Read-back verified** the app's correct path, its single owner-only policy, Turnstile mode and domain, and unchanged Production/Staging Worker versions.
- **Still pending:** Actual allowed/denied Access browser sessions, real Siteverify token + replay/outage tests, provisioning of new *approved* Worker binding/secret values, production VAPID setup, approved Pre-production HTTP and independent Backup/Restore certification.

**Gate 1: Production Access created and owner-authorized browser login PASS, but disallowed-identity rejection is still unverified. Gate 2: Production Turnstile widget created, but server-side Siteverify integration has not been enabled or tested. Production Release remains NO-GO.**

## Live Access browser acceptance — owner action (no deployment)

### Verified owner login result — PASS (2026-11-16)

The authorized owner opened the Production Access-protected Admin Push URL in an **incognito/private browser**, observed the Cloudflare Access login challenge, completed sign-in and then saw the current Production Worker's JSON **`{"ok":false,"error":"Not Found"}`**. That `404` response is **expected after successful Access authentication** because the currently deployed `0.5.41.5-phase1` Worker has not implemented this new path yet.

An independent, read-only Cloudflare Access authentication-log query returned **2 Allow events** associated with the new Production Access application's ID and **0 Deny events** in the retrieved log window. The log events corroborate the owner browser report. Event counts do not indicate distinct identities. The Production Worker deployment version was independently checked and remained unchanged.

**Owner-authorized sign-in: PASS.** **Denied/disallowed identity: NOT TESTED YET**, so the full Access acceptance gate is still pending. No passwords, OTP, owner email, cookies, Access tokens or identity details were recorded. No Worker, database, secret, Access policy or Turnstile setting was modified.


**Verified by read-only API inspection:** The new Access app covers `arcscriptcenter-api.kogpasan14.workers.dev/api/v1/admin/push/*`, is linked to exactly one reusable Allow policy for the authenticated Cloudflare owner, and has an Access application AUD. The most recent read-only Access authentication logs contained **zero identifiable events for this new application**. This is **not** evidence of a successful login or a denial. A Cloudflare policy-test API call without a user identifier failed with `invalid_user_id`; no security control was bypassed or changed.

**Owner test URL:** https://arcscriptcenter-api.kogpasan14.workers.dev/api/v1/admin/push/

1. Open the URL in a **private/incognito browser window**, without signing in, and note whether Cloudflare Access shows a sign-in challenge rather than sending the request directly to the old Worker.
2. Authenticate with the **authorized owner identity** through the normal Cloudflare Access interface. Never share a one-time sign-in code, password, identity token, cookie or screenshot of credentials.
3. After Access authentication succeeds, the existing Production Worker may correctly reply with **`404 Not Found`** for this path: the current live Worker is version `0.5.41.5-phase1` and does **not yet implement** the new Admin Push URL. **A post-authentication Worker 404 is expected and must not be misreported as a failed Access login.**
4. To prove disallowed identity rejection, a separate controlled attempt using an identity that is **not included** in the owner policy is still necessary; never add a broad Everyone/Email Domain policy just to make testing easier.
5. Only after those browser observations, recheck *aggregated* Access authentication logs filtered to the new app; do not copy user emails or authentication events into GitHub.

**Next gate after browser confirmation:** owner-controlled binding/secret authorization and real Siteverify integration. Neither is authorized by this browser test. The existing Worker, D1, secrets, Access policy and Turnstile widget must remain unchanged for this acceptance check.

## Completed and accepted

- Sandbox Stage16.75 Web Push automatic retry: live Cloudflare Cron and Push Service accepted delivery on attempt two (HTTP 201); owner confirmed Android notification receipt. Synthetic QA data deleted.
- Production Candidate assembled privately from exact hash-pinned Production and Sandbox source. Existing Production route body preserved, dummy Turnstile and Sandbox-only test routes removed.
- Production-specific Cron health fixed to `production_push_cron` with idempotent operational bootstrap, verified in separate disposable real D1 and deleted afterward.
- Android Push page changed to `/api/v1/admin/push/`, inside the Service Worker scope.
- **Latest Candidate SHA-256:** `9da9cf8a19995d3058d8f292424c49074377b3e5a7fe4727c31b65fce73e4841` (review only).
- **35/35 offline tests PASS** (28 Node + 7 SQLite).
- Production/Staging/Sandbox D1 Time Travel bookmarks available; `quick_check=ok`, 0 foreign-key violations. This does **not** certify a Production backup restore.
- Cloudflare Preview accepted an **older** Candidate for compilation; HTTP calls were blocked by the tool's network policy. This does **not** certify HTTP behavior of the latest Candidate.
- Existing Production and Staging Workers have stayed unchanged.

## Four remaining release gates, not new engineering stages

| Gate | Owner/operator must do | PASS evidence required |
|---|---|---|
| 1. Cloudflare Access | **Provisioned** a production-host path-only app with a single owner allow policy; do not re-create. Existing Admin routes and GitHub integration unchanged | **Pending:** allowed/denied browser sessions and app AUD bound to Candidate |
| 2. Real Turnstile + Push | **Managed Widget provisioned** for production domain and sitekey available; do not re-create. **Pending:** approved server secret installation and Production VAPID credentials | Real Siteverify hostname/action and invalid/replayed/outage tests; authorized Android subscription and Push |
| 3. Recovery + HTTP acceptance | Obtain a verified independently accessible Production D1 backup/export and prove a controlled restoration procedure; run approved real HTTP pre-production tests | Recovery evidence and rollback operator identified; legacy routes, Feedback/Appeal, Access, Turnstile and device Push verified |
| 4. Final approval + rollout | Separately authorize Production D1 migration, Worker deployment, binding changes and Cron activation only after gates 1–3 | Pre-release backup bookmark, additive migration, canary checks, Cron/Outbox and rollback plan accepted |

**Do not copy** Sandbox Turnstile secret, Access identity/AUD, VAPID private key, Push subscriptions, test records, Stage16.72/16.73 control tables or QA-only features into Production.

### Configuration inventory (names only, never values)

Retain Production: `DB`, `ARCSCRIPT_ADMIN_KEY`, `ARCSCRIPT_POLICY_SIGNING_KEY`, `ASC_ANALYTICS_HASH_KEY`, `GITHUB_TOKEN`.

New settings after approval: `ASC_RELEASE_CHANNEL` (`production`), `ASC_RELEASE_HOSTNAME`, `ASC_TURNSTILE_HOSTNAME`, `ASC_TURNSTILE_MODE` (`real`), `ASC_TURNSTILE_REAL_SECRET`, `ASC_FEEDBACK_QUOTA_KEY`, `ASC_PUSH_ACCESS_AUD`, `ASC_PUSH_ADMIN_EMAIL_SHA256`, `ASC_PUSH_VAPID_PRIVATE_JWK`, `ASC_PUSH_VAPID_PUBLIC_KEY`. Any client-side public sitekey must correspond to the production-specific widget. Use the Cloudflare secret store; do not paste secrets into GitHub or chat.

Current verified configuration: the Production Worker uses `arcscriptcenter-api.kogpasan14.workers.dev`; dedicated owner-only Access and a distinct production-host-only Turnstile Widget were created without touching the existing Production Worker, Sandbox Access, or Sandbox Widget. Live authentication and the new Worker secret bindings remain pending.

### Deployment order (only after separate Production authorization)

1. Pin current Production Worker version, D1 schema, and recovery bookmark; confirm independent backup/restore procedure and rollback operator.
2. Apply reviewed **additive** Feedback/Appeal schema then Production-only Push/Cron schema with `production_push_cron` seed. No Sandbox data.
3. Deploy reviewed Candidate while preserving legacy Production bindings and routes; use bounded exposure.
4. Verify authorized Access, real Siteverify, Feedback/Appeal, signed policy, Android Push subscription and live automatic retry. Enable Cron only after approved handler, credentials, schema and telemetry are ready.
5. Record release result and close the work. If any hard gate fails, use pre-approved rollback; do not improvise changes on live data.

**Current decision: NO-GO.** No more redundant Stage work. Access/Turnstile resource creation and owner-authorized Access login are complete; next dependencies are **disallowed-identity rejection**, approved server-side Siteverify and VAPID integration, approved HTTP testing, and recovery proof. Separate authorization is required before any Worker bindings/Secrets or Production deployment/migration change.
