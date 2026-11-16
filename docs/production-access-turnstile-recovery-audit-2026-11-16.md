# ArcScriptCenter — Production Access, Turnstile and Recovery Audit

Date: 2026-11-16 (Asia/Bangkok). **Read-only live Cloudflare inspection and offline GitHub security QA. PRODUCTION NO-GO.**

## Observed platform and security configuration

- **Worker bindings:** Production and Staging each have 5 existing bindings (including DB, ARCSCRIPT_ADMIN_KEY, ARCSCRIPT_POLICY_SIGNING_KEY, ASC_ANALYTICS_HASH_KEY and GITHUB_TOKEN). Neither currently has the new Production Release Channel, real Turnstile Siteverify binding, Push Access AUD or VAPID credentials. Sandbox has 12 bindings, but these must **not** be copied to Production.
- **Cloudflare Access:** The account-level Access Apps API returned 2 self-hosted applications, each with one policy and an audience value. The available domain metadata did **not** establish a Production application that covers the intended new Admin Push endpoint. This is an *unverified coverage blocker*, not a categorical assertion that no Access policy exists anywhere.
- **Turnstile:** The account-level widgets API returned 1 managed widget, associated with the Sandbox host. **No independent production-host-matched widget was identified**. A dedicated real Production sitekey/secret and siteverify hostname/action checks are mandatory before enabling submissions.
- **Worker Access identity:** Cloudflare documents ctx.access and getIdentity() as the supported mechanism for an Access-protected Worker. The Candidate additionally compares the application audience and an admin email hash. This must be verified with the actual permitted admin identity and disallowed-account cases; synthetic tests alone cannot establish correct live Access policy deployment.
- **Release Candidate security gate:** The GitHub-branch-only candidate checks production release channel, real Turnstile mode, exact host relationship, minimum-format confidential bindings, valid-looking Access audience/admin hash, VAPID fields and DB. This is a **structural guard only**: fake strings of the right length may pass it, so it does not replace actual secret, VAPID signing or Access authentication verification.

## GitHub offline security verification

- GitHub Actions **43873600377 — SUCCESS**: 28 Node tests (6 Push scope/route contract tests plus 22 synthetic environment security tests), 7 Python SQLite Production Cron bootstrap tests; **35/35 PASS**.
- The security tests assert fail-closed behavior when Release Channel, real Turnstile, matching hostname, Siteverify secret, quota key, Access Audience, Admin identity hash, VAPID keys or DB binding is missing/incorrect. These use **synthetic values only**, not real customer data or credentials.
- This is **not** a Production HTTP test or proof of Turnstile token validation in a real browser, and does not approve Production deployment. The Cloudflare Preview HTTP check remains unavailable through the current authorized tool connectivity; no alternative-route bypass was attempted.

## D1 data integrity and recovery audit

| Environment | Storage | Time Travel bookmark | Quick check | Foreign key violations |
|---|---|---|---|---|
| Production | production | available | ok | 0 |
| Staging | production | available | ok | 0 |
| Sandbox | production | available | ok | 0 |

All above checks were Cloudflare **read-only** requests; no Production/Staging/Sandbox data was updated. The independent Cloudflare docs confirm D1 Time Travel is available on the modern storage subsystem and retains point-in-time restore history for up to **30 days**, subject to its documented terms. Bookmark availability is **not an independently certified restored backup**.

### Required owner-approved recovery drill

1. Freeze the exact current Production Worker version, database schema and a pre-change D1 Time Travel bookmark. Determine responsible operator, maintenance window, acceptable data loss and failure trigger.
2. Prove an independently accessible backup/export can be recovered into a separate, controlled D1 **without sharing private user rows in chat, logs or GitHub**. A disposable synthetic database is suitable for rehearsing the restore mechanism but does not by itself certify the private Production backup.
3. Rehearse the approved two-part rollback plan: Worker version rollback and D1 restore are **separate operations**. A D1 restore may reverse later legitimate writes and therefore needs explicit operational approval.
4. Validate legacy routes, signed policy, Admin Access, Feedback/Appeal schemas and device Push re-subscription after a restore. Confirm no unexpected duplicates or loss of accepted submissions.
5. Never perform Production restore, migration, secret change, Worker deployment or Cron activation under this review-only authorization.

## Production release GO/NO-GO checklist

- [x] Read-only current Worker binding inventory (secret **names/types** only)
- [x] Access application and Turnstile widget discovery (read-only)
- [x] 35/35 offline security, scope and Cron SQL tests
- [x] All three D1 integrity checks, foreign key checks and bookmarks
- [ ] Owner-controlled Production domain + Access application/policy configured and verified with allowed and denied identities
- [ ] Dedicated Production Turnstile widget and real Siteverify action, hostname, invalid-token and outage tests
- [ ] Dedicated Production VAPID keys/admin registration + validated Service Worker under the Production origin
- [ ] Actual approved HTTP preproduction verification (no network bypass)
- [ ] Independently verified Production backup/export and restore + rollback authorization
- [ ] Explicit Production release approval

**Decision: NO-GO.** Existing Production and Staging Workers, D1 contents, Access policies, widgets and Secrets were not modified.

## Official documentation

- Cloudflare Workers Access: https://developers.cloudflare.com/workers/configuration/cloudflare-access/
- Turnstile Siteverify: https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
- D1 Time Travel: https://developers.cloudflare.com/d1/reference/time-travel/
