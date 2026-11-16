# ArcScriptCenter — One-Page Production Release Closure

**2026-11-16 · Review only · PRODUCTION NO-GO**

This is the single operational owner handoff. Stop adding new Stage IDs and unnecessary repeated audits. **No Production/Staging deployment, D1 migration, Secret change, Access policy change or Cron activation has been authorized.**

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
| 1. Cloudflare Access | Confirm the intended Production hostname and authorize a dedicated Access policy for new Admin Push endpoints; preserve existing Production Admin routes and GitHub integration | Allowed admin login succeeds; unauthenticated and disallowed identity fail; app AUD matches Candidate binding |
| 2. Real Turnstile + Push | Configure a separate production-host-matched Turnstile widget, client sitekey, server-only Siteverify secret and distinct Production VAPID credentials; configure owner-controlled release bindings | Exact hostname and action verified; invalid/replayed/outage tokens rejected; authorized Android subscription and Push works |
| 3. Recovery + HTTP acceptance | Obtain a verified independently accessible Production D1 backup/export and prove a controlled restoration procedure; run approved real HTTP pre-production tests | Recovery evidence and rollback operator identified; legacy routes, Feedback/Appeal, Access, Turnstile and device Push verified |
| 4. Final approval + rollout | Separately authorize Production D1 migration, Worker deployment, binding changes and Cron activation only after gates 1–3 | Pre-release backup bookmark, additive migration, canary checks, Cron/Outbox and rollback plan accepted |

**Do not copy** Sandbox Turnstile secret, Access identity/AUD, VAPID private key, Push subscriptions, test records, Stage16.72/16.73 control tables or QA-only features into Production.

### Configuration inventory (names only, never values)

Retain Production: `DB`, `ARCSCRIPT_ADMIN_KEY`, `ARCSCRIPT_POLICY_SIGNING_KEY`, `ASC_ANALYTICS_HASH_KEY`, `GITHUB_TOKEN`.

New settings after approval: `ASC_RELEASE_CHANNEL` (`production`), `ASC_RELEASE_HOSTNAME`, `ASC_TURNSTILE_HOSTNAME`, `ASC_TURNSTILE_MODE` (`real`), `ASC_TURNSTILE_REAL_SECRET`, `ASC_FEEDBACK_QUOTA_KEY`, `ASC_PUSH_ACCESS_AUD`, `ASC_PUSH_ADMIN_EMAIL_SHA256`, `ASC_PUSH_VAPID_PRIVATE_JWK`, `ASC_PUSH_VAPID_PUBLIC_KEY`. Any client-side public sitekey must correspond to the production-specific widget. Use the Cloudflare secret store; do not paste secrets into GitHub or chat.

Current read-only account discovery: the existing Production Worker has `workers.dev` enabled but the intended hostname must still be explicitly confirmed; there are 2 Access apps but production host policy coverage is unverified, and 1 Turnstile widget matched Sandbox rather than Production.

### Deployment order (only after separate Production authorization)

1. Pin current Production Worker version, D1 schema, and recovery bookmark; confirm independent backup/restore procedure and rollback operator.
2. Apply reviewed **additive** Feedback/Appeal schema then Production-only Push/Cron schema with `production_push_cron` seed. No Sandbox data.
3. Deploy reviewed Candidate while preserving legacy Production bindings and routes; use bounded exposure.
4. Verify authorized Access, real Siteverify, Feedback/Appeal, signed policy, Android Push subscription and live automatic retry. Enable Cron only after approved handler, credentials, schema and telemetry are ready.
5. Record release result and close the work. If any hard gate fails, use pre-approved rollback; do not improvise changes on live data.

**Current decision: NO-GO.** No further tests should be invented just to delay the release. The next real dependency is an **explicit owner choice** about Production Access/Turnstile configuration. Configuring these services is separate from authorization to deploy or migrate.
