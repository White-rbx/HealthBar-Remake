# ArcScriptCenter — Admin Dashboard / User's Case (STAGING, review only)

**Status:** Prepared with a local source bundle and six passing synthetic Node tests. NOT deployed. Production untouched.

## Request
Add **User's Case** inside the existing Admin Dashboard → Feedback & Appeal. Do not introduce a separate admin login or duplicate sidebar. The UI contains:

- `Search User (empty = all)`
- One entry per claimed UserId, plus **Unknown / Unlinked** for Feedback without an ID
- A count of total cases, Review, Approved, Denied, Flagged (Policy)
- Click a user to see their cases; click a case to reuse the existing private Admin Case Review
- Previous/Next pagination for all groups and each user's cases

## Data trust requirements
The database field `claimed_user_id` is **client-provided/unverified**; it cannot prove an account owns a case. Do not label a record with Roblox Username or avatar unless a server-verified mapping exists. Numeric UserId prefixes are the only currently supported search; empty search includes all groups. The `violation` status of a Feedback case is **Flagged (Policy) · Closed**, NOT proof that the Roblox account has a violation notice or is banned. No account-private Violation history is exposed by this feature.

## API boundary
Use the existing admin authentication and same origin policy from `fcAdmin`; **never rely on client-only hiding**. The source bundle contains:

- `feedback-admin-users-case.mjs` exports `createAdminUsersCaseHandler({adminAuthenticated,originAllowed})`
- `feedback-admin-users-case-ui.mjs` exports `mountUsersCaseSection(existingFeedbackPage,{loadUsers,loadCases,onOpenCase,isAdminUnlocked})`
- `feedback-admin-users-case.test.mjs` tests auth, search, paging, no unlinked-case leakage and flagged-case grouping

Review-only proposed routes (not registered in deployed Worker):
- `GET /api/v1/admin/feedback/users?search=&page=0` returns groups, 20 per page
- `GET /api/v1/admin/feedback/users/cases?subject=unlinked&page=0` or `subject=<numeric ID>` returns receipt-free case summaries, 25 per page

Input is strictly validated; SQL uses parameterized bindings; removed cases are excluded. Neither endpoint returns case Receipts, admin keys, raw IP, or private history. No wildcard account-wide lookup is exposed to public users.

## Safe integration path
1. Obtain and review the **exact deployed** STAGING Pages source of `/__asc1649/feedback-appeal.js` and its existing admin auth/session helper. It is external to this GitHub repo; replacing it blindly risks breaking the owner-designed UI.
2. Integrate into the existing Feedback & Appeal panel and reuse the already-authenticated fetch/case-selection callbacks. Ensure the panel is hidden on admin lock.
3. Wire the two routes behind the live Worker admin auth middleware (not in a public handler), preserving existing status-by-receipt behaviour.
4. Exercise synthetic admin search, empty/all, unknown ID, pagination, case selection and lock/logout in an isolated STAGING deployment; ensure public request returns 401/403.
5. Only after STAGING acceptance consider a separate Production release decision. PR #16 remains Draft.

**Mobile client status:** An independently prepared Arcsen UIs 7.3.49 patch displays a receipt-verified Feedback case whose status was changed to `violation` in its own **Flagged (Policy)** section. This does not enable the separate account-bound Violation tab. Optional UserId submission is off by default and always labeled unverified.


## Username-first Admin Directory implementation (18 Nov 2026)

Following the owner's request, the review implementation has been added as **actual source files** under `sandbox/` in this PR:

- `feedback-admin-roblox-directory.mjs`: fixed-host read-only Roblox public name resolution (GET `/v1/users/search`, POST `/v1/users`) with strict validation, bounded 10-profile search results, 20-ID batch lookup, 5-minute in-memory cache, 4.5s timeout, and no secrets/receipts/user-auth assertions.
- `feedback-admin-users-case.mjs`: private, existing-auth-only paged search accepting Username, Display Name or UserId; joins public result IDs to **only** STAGING Feedback cases whose `claimed_user_id` matches. Blank search lists all, including Unknown / Unlinked. No automatic ownership transfer.
- `feedback-admin-users-case-ui.mjs`: native, injected Admin section with Username / Display Name / UserId search, row counts, case selection and existing Admin Case Review hand-off. It does not add a new Login.
- `arcscriptcenter-ban-types-staging.mjs` and `arcscriptcenter-admin-ban-directory.mjs`: enhance the **existing authenticated managed Ban List** using public profile display names and classify Banned / Temporary Banned / Expired / Scheduled. Multiple accounts with the same display name remain separate matching results and must be selected by UserId.
- `feedback-admin-directory.test.mjs`: check auth-before-Roblox-fetch, ambiguous display names, claimed-ID lookup, missing-identity fallback, ban types and offline Roblox behavior.

**QA:** 16/16 local synthetic Node tests PASS in the downloadable source kit; checked-in GitHub CI passed its Admin Directory test step in [run 44291754546](https://github.com/White-rbx/HealthBar-Remake/actions/runs/44291754546). Live external Roblox API, native Pages JS integration, and Admin UI clicking **not yet tested**.

**Read-only STAGING D1 inventory on the same date:** 7 non-removed Feedback cases: **4 with claimed UserId** and **3 unlinked**. This is why the admin cannot identify every submitter by name even with Roblox public lookup. The remaining 3 must stay Unknown / Unlinked unless owners voluntarily re-identify through an authenticated process; do not guess or link by display name.

**VERY IMPORTANT deployment stop:** The canonical STAGING Pages deployment remains `3a36ea6d-d867-45a0-931d-87f6df64ed8c` with Pages Functions enabled. The source-kit ZIP is **not** a Pages deployment artifact: it has NO `index.html` or native Functions. The 18 Nov dashboard outage was caused by deploying a similar review-only ZIP in place of the full site. Never repeat. Obtain/review the live deployed native Pages JavaScript and integrate in an isolated preview before any canonical rollout.

**Security boundary:** Roblox public profile name ≠ verified account ownership. Neither claimed UserId nor a matched public name proves an account wrote a case or is subject to a ban. Ban List and unban operations remain existing Admin-only actions keyed by UserId; user-facing Violation still needs independently authenticated subject linkage. No Cloudflare resources or Production altered by this source update.
