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
