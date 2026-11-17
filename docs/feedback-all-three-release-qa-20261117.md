# ArcScriptCenter — All Three Steps, One Test Round

**Date:** 2026-11-17  
**Release state:** **QA candidate ready for owner testing; NOT deployed to Production.**  
**PR:** https://github.com/White-rbx/HealthBar-Remake/pull/16 (Draft)

This report combines **Anti-spam hardening**, **additive Production Candidate**, and **final QA / rollback** without repeating the unsuccessful production SQL export process. All new data and HMAC tests were performed on synthetic fixtures or a separate Cloudflare D1.

## 1. Anti-spam code: ready for review

New: `sandbox/feedback-release-rate-guard.mjs`, exercised by `sandbox/feedback-release-rate-guard.test.mjs`.

- Per independently verified edge-network: 6 submissions per 15-minute window, 24 per day.
- Shared global safety limit: 240 submissions per 15-minute window, 4000 per day.
- **No OAuth or user ownership verification** is required to submit general Feedback. `claimedUserId` remains unverified metadata.
- Identifiers stored in D1 are HMAC-SHA256 scope hashes only: **no raw IP, Roblox ID, receipt or key**.
- Quota uses atomic D1 upserts; a saturated individual network does not consume further global quota.
- Missing trusted Cloudflare ingress, HMAC key or D1 results in **fail-closed 503**, not open access.
- Initial limits are review values, not a settled launch policy. Multiple users behind one NAT may share a bucket; evaluate Android/mobile usage before Production release.

**Security dependency:** `CF-Connecting-IP` is intended to be Cloudflare edge-attested for direct external requests. Same-zone Worker subrequests can alter its provenance. The review candidate therefore rejects known Worker hops and requires `request.cf` metadata. **This ingress adapter must be reviewed independently at the intended deployed hostname and WAF before being considered Production-safe.** Never accept `X-Forwarded-For`, JSON body or client UserId as the network authority.

## 2. Minimal Production Candidate + D1 migration: review-only

New: `sandbox/feedback-release-candidate-builder.mjs` — builds an additive private Worker review artifact from the **exact pinned** currently deployed Production and STAGING Worker JavaScript sources. It never copies the full STAGING Worker blindly.

Source pins:
- Production SHA-256: `036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48`.
- STAGING SHA-256: `cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62`.

Builder inserts the reviewed Feedback/Appeal API and Violation lookup routes into the existing Production handler, preserves legacy route bodies, removes obsolete STAGING global quota and origin allowlist references, and adds the D1 HMAC rate gate. It fails on source drift, duplicate routes or missing security anchors. Generated Worker is marked **REVIEW_ONLY_DO_NOT_DEPLOY** and kept private.

New: `migrations/feedback_release_additive_REVIEW_ONLY_20261117.sql`, captured from **current live STAGING sqlite_master** plus one new HMAC quota table/index. Contains **7 tables, 10 explicit indexes, 4 history triggers**, no user records, DROP, UPDATE or DELETE.

Do not run migration against Production without separate schema review. The actual Production D1 still lacks Feedback tables; a Worker rollout before schema preparation would cause errors. Secret `ASC_FEEDBACK_RATE_SECRET` must be separately provisioned and ingress provenance checked; it is not in GitHub.

## 3. One QA run, rollback and release gates

**Node / GitHub CI** — synthetic tests include D1 quota concurrency, independent network quotas, daily reset, no client-supplied UserId authentication, D1 fail-closed, SQL additive schema/history triggers, and exact Worker source-pin review.

**Live Cloudflare D1 rehearsal:** created isolated, unbound `asc-feedback-release-qa-20261117` (`fb828e2b-b10b-41ac-95bd-3873ff3cccd5`). Applied 19 exact approved STAGING DDL objects + 2 quota objects. Verified **7 tables / 10 indexes / 4 triggers**. In a synthetic D1 rate test one network obtained **6 accepted + 1 denied** while a different network still succeeded. Feedback create/review audit triggers passed. Then all synthetic cases, audit rows and rate windows were **deleted from the isolated test DB**. `PRAGMA quick_check=ok`, zero foreign key violations. **No real user data was copied into this test DB.**

Existing STAGING Dashboard: https://arcscriptcenter-dashboard-staging.pages.dev/#feedback-appeal. The owner already verified normal Feedback/Appeal case review, including `Claimed UserId (unverified)`, in STAGING. The newly written rate gate and Production Candidate have **not** been installed in that live STAGING Worker yet; do not treat the existing Dashboard as proof of the new limiter.

### Rollback anchors (checked previously)

| Service | Last known pre-release version |
|---|---|
| Production Worker `arcscriptcenter-api` | `298de84d-418c-489c-b133-c549c785f66e` |
| Production Dashboard Pages | `b3bb02db-229c-46ec-a69b-3322359778f2` |
| STAGING Worker `arcscriptcenter-api-staging` | `374b23ac-98ec-45f2-a586-03bb262db72b` |
| STAGING Dashboard Pages | `3a36ea6d-d867-45a0-931d-87f6df64ed8c` |

Reverify these IDs immediately before any future release: deployments can change. Never restore an old Production D1 snapshot over newer user records merely to roll back a Worker. Additive schema migration does not need automatic destructive rollback.

### Stop conditions (Production NO-GO)

1. Compiled private Candidate's syntax, legacy route regression, and all Admin-only / receipt-only access controls must pass with current runtime. Synthetic fixture tests alone do **not** prove real assembled Worker correctness.
2. Independently validate edge-trusted network metadata, rate denial/recovery under real mobile STAGING requests, and error messages. Reject duplicate ingress, spoofed headers and untrusted Worker subrequests.
3. Review exact additive D1 schema and apply only under separate authorization; ensure no partial objects or broken old bindings.
4. Verify required Worker secrets in Cloudflare without exposing values, CORS for Production Dashboard, no OAuth requirement for ordinary Feedback and no unverified-ID-based private Violation History.
5. Review Production data recovery limitation (official exported SQL still not downloaded/imported) and rollback feasibility. This pass does NOT repeat the Backup attempt.
6. Obtain **explicit owner Production approval** after a green end-to-end acceptance. Do not merge Draft PR #16 or deploy Production automatically.

**Outcome:** All three engineering workstreams are packaged for a **single owner review / QA round**, not three more stages. Only the isolated QA D1 was created/changed. Production and existing STAGING Workers/Pages/D1 are untouched in this round.

## Additional private source merge preflight — live Workers (read-only)

Using the current Cloudflare-connected Production and STAGING Worker source in **memory**, strict source pins matched. A dry review assembly of the Feedback core, Admin extensions, a rate-guard wrapper and a small legacy-preserving route overlay produced **104,613 bytes** of source text. The old shared STAGING quota block was removed, and the original Production ban-check route was still present. Only a diagnostic summary was returned, never the assembled private Worker source or secrets.

**Important verification limit:** Cloudflare's connector refused dynamic source compilation with `Code generation from strings disallowed for this context`. Therefore runtime/syntax validation of that exact full live-source merge is **NOT PASSED**, and the private review candidate must not be deployed. The GitHub builder's 15-route synthetic fixture tests and the original Worker source hash checks are independent evidence, not a substitute for compiling and executing the complete assembled Worker in an isolated runtime. This must be completed before any Production approval.

The new limiter has also **not** been deployed to the current STAGING Worker. Only the new isolated synthetic QA D1 was created and used. Owner testing can review this PR's QA and local suite in one round, but cannot yet validate the new limiter via the live Arcsen STAGING API.
