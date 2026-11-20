# ArcScriptCenter — Isolated Preview Runtime QA (2026-11-17)

**Outcome:** Cloudflare Preview deployment API **PASS**; live HTTP invocation **BLOCKED (404)**; runtime Anti-spam test **NOT VERIFIED**. Production and the existing live STAGING worker remain unchanged.

## What was attempted

1. Cloudflare created a Preview named `feedback-runtime-qa-20261117` for the existing isolated sandbox Worker `arcscriptcenter-merge-sandbox-1658`.
2. Deployed a synthetic-only QA module via the Preview Deployment API with a D1 binding to **`asc-feedback-release-qa-20261117`**, an isolated database with no real user submissions, and generated test-only secrets. Preview deployment returned **success** and a URL.
3. Enabled preview URLs **only on the Sandbox Worker** (original value was `previews_enabled=false`; its existing main Worker deployment remained untouched).
4. GitHub Actions attempted to POST once to the named Preview URL and to immutable Preview deployment URL. Both returned **HTTP 404**. See:
   - https://github.com/White-rbx/HealthBar-Remake/actions/runs/44127553872
   - https://github.com/White-rbx/HealthBar-Remake/actions/runs/44127865246
5. To disambiguate route mismatch vs application failure, published a diagnostic **Preview-only** Worker module that would answer **HTTP 418 on every path and method** and had **no DB or secrets**. The GitHub runner still got HTTP 404 on the named Preview URL. Its immutable fallback targeted the prior deployment and also got 404. This strongly suggests Preview URL routing was not reaching the intended Preview module; it does **not** establish whether the HMAC limiter would pass live runtime.
6. The isolated D1 `asc-feedback_release_qa` was checked after these requests. The correct database is **`asc-feedback-release-qa-20261117`**. Query result: **0 rows in `asc_feedback_rate_windows`**, consistent with the test handler never being invoked.

## Cleanup completed

- **Deleted** Preview `feedback-runtime-qa-20261117` (ID `a68f6c86f71d4dcc9b2498b15eb7e242`).
- Restored `arcscriptcenter-merge-sandbox-1658` to its original `previews_enabled=false`, preserving `workers.dev enabled=true`.
- Confirmed its main active Worker version **`bc4e8484-8901-4e0a-9d19-a20120f59ac8`** unchanged.
- Left the separate synthetic-only D1 database intact for future authorized isolated tests; it has **0 QA rate-window rows**. Test secrets were not written to GitHub.
- Rechecked real Production Worker version **`298de84d-418c-489c-b133-c549c785f66e`**, Production Pages deployment **`b3bb02db-229c-46ec-a69b-3322359778f2`**, and live STAGING Worker version **`374b23ac-98ec-45f2-a586-03bb262db72b`**: unchanged.
- This isolated Preview work did **not** merge PR #16, deploy the Candidate, modify existing Production/STAGING D1 schemas or touch actual user case records.

## Evidence that DID pass

- The source-attested, 106,382-byte combined Worker Candidate was accepted by Cloudflare's separate Worker **Version Upload** API as undeployed version `c066e912-3623-4c00-9c04-1184559a1b77`. Active Sandbox traffic remained 100% on its previous version; the QA-only version had no D1/secret bindings.
- The HMAC Anti-spam limiter and additive D1 schema passed Node/SQLite tests and an earlier **direct D1 API** test (6 accepted, 7th denied, another synthetic network accepted; history triggers and `quick_check` passed).
- The consolidated GitHub Actions regression tests previously passed. **Do not conflate** the independent green regression suite with these failed live Preview HTTP tests.

## Remaining release blocker

**Live HTTP runtime testing of the new Candidate against isolated D1 is still required.** Cloudflare Workers Preview URL routing (or account preview configuration) needs troubleshooting independently of the limiter implementation. The Preview error should not be “fixed” by weakening Admin authorization, spoofing network identity, bypassing Roblox checks, or pointing a public Preview at Production D1.

Owner can inspect the Cloudflare **Workers & Pages → Sandbox Worker → Settings → Domains & Routes** Preview URL configuration when resuming this specific infrastructure check. Do not automatically promote Production while runtime verification is blocked.

**Release disposition:** Draft review only. No Production deployment or new backup attempt.
