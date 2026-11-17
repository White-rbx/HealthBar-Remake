# STAGING Feedback UserId acceptance — 2026-11-17

**Current status: STAGING UI render passes synthetic offline QA; real native Feedback-with-UserId end-to-end test is still open.**

## Read-only aggregate from existing STAGING D1

Query performed by the connected Cloudflare tool on `arcscriptcenter-staging`, grouped by type; **no individual cases, IDs, details, receipts, users, or credentials were retrieved.**

| Case kind | Total | Cases with `claimed_user_id` |
| --- | ---: | ---: |
| Appeal | 2 | 2 |
| Feedback | 1 | 0 |

The owner previously verified an **Appeal** in Admin Case Review via screenshot; that does not prove the new Feedback-with-UserId path yet.

## Offline Chromium browser test with the preserved native UI

The existing Stage16.54-derived, source-attested STAGING Dashboard candidate was loaded with external networking disabled and a synthetic, in-memory **GET-only** mock Admin API. The test used no Admin secret or real case data.

**Passed on mobile 390×844 and desktop 1280×900:**

- Original Feedback & Appeal panel, native Admin Unlock and case list; no extra sidebar item.
- Synthetic Feedback with UserId: `123450001 (unverified)`.
- Synthetic Feedback without UserId: `Not provided (unverified)`.
- Synthetic Appeal with UserId: `123450003 (unverified)`.
- Native per-case selection and history fetch against mock GET endpoints.
- Native Lock empties displayed cases; no JavaScript page errors or API mutations.

Saved an owner-facing ChatGPT QA archive: `ArcScriptCenter_Feedback_UserId_Offline_QA_20261117.zip`, containing two synthetic-only screenshots, a JSON test result and README. These are **offline** screenshots; never pass them off as real backend records.

## Browser Rendering rate limit

Cloudflare Browser Rendering returned HTTP **429** and explicitly requested no further calls for a period. **No retry** was made against that service. Tests continued locally against the source-attested candidate instead. This limitation does not affect the earlier successful STAGING Pages deployment or read-only D1 aggregate query.

## Final operational acceptance gate

A real Feedback record with an optional `claimedUserId` must travel **Arcsen native STAGING client → deployed API Worker → STAGING D1 → authenticated Admin Dashboard case review**. The current STAGING database has **zero** Feedback cases carrying an ID, so this has not been demonstrated.

The owner can submit a clearly labeled test Feedback using native Arcsen and review it privately in `https://arcscriptcenter-dashboard-staging.pages.dev/#feedback-appeal`, keeping Admin Key, Case ID and Receipt private. Confirm the UserId displays as an **unverified** identifier. Remove the test record via its private receipt once verification is complete if the UI permits.

Existing Production Pages and Production D1 are **unchanged**. No D1 rows were inserted, changed or deleted in this pass. PR #16 remains Draft. Do not promote to Production on the strength of mock-only UI tests.
