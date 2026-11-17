# ArcScriptCenter — Feedback Inbox STAGING Integration (2026-11-17)

**Status:** STAGING Worker updated; GitHub-built Dashboard HTML preview passed; **Pages Dashboard and Production are not deployed**.

## 1. STAGING Worker backend — deployed

Worker: `arcscriptcenter-api-staging`.

- New version: `374b23ac-98ec-45f2-a586-03bb262db72b` (version 41)
- New deployment: `82734ec2-f850-4474-bfea-f598aafec19b`, 100% STAGING
- Prior 100% version for rollback: `5b5040fb-6c04-4029-9c53-af15d3dda888`
- Source adaptation: exact existing `fcSubmit` UserId claim block only.
- Both Feedback and Appeal may store a *user-supplied numeric claim*, using the EXISTING `asc_feedback_cases.claimed_user_id` column. Feedback may omit it; Appeal still requires a numeric claim.
- No OAuth or Pairing identity claim is granted. A submitted ID never authorizes case history or moderation decisions.
- Strict inherited bindings preserved: `ARCSCRIPT_ADMIN_KEY`, `ARCSCRIPT_POLICY_SIGNING_KEY`, `ASC_ANALYTICS_HASH_KEY`, `DB`, `GITHUB_TOKEN`. No secret values read or committed.
- Compatibility date preserved `2026-11-13`. No D1 schema migration.
- Postdeployment `GET /api/v1/health` was reachable and reported `ok:true`, `status:online`, `database:connected`; existing version display string remains `0.5.67.1-cors-response-staging` because only the claim block was changed.

**Limit:** No postdeployment synthetic Feedback submit / private Admin authenticated E2E was executed by this tool session, to avoid creating user records or handling Admin credentials. The owner reported previous Sandbox/Arcsen testing had passed, but that does not prove the newly deployed STAGING Worker path end to end.

## 2. Dashboard Pages — important correction after full browser QA

**Do not deploy the earlier duplicate-tab preview ZIP.** The original STAGING Dashboard already has a fully designed Feedback & Appeal area. Its route is `#feedback-appeal` (not `#feedback`), and the original HTML includes:

- Navigation `data-page="feedback-appeal"` with `id="asc1649FeedbackNav"`.
- Existing `<section id="page-feedback-appeal">`, case queue, Admin Key unlock, filters, selected-case editor, follow-up tools and moderation activity.
- External Pages Functions assets `/__asc1649/feedback-appeal.js` and `/__asc1649/feedback-appeal.css`. Those are **NOT** among the static files in the local ZIP and must be verified on the hosted Pages environment.

The initial code scan missed this because it searched for literal `feedback` in `data-page` values instead of also recognizing `feedback-appeal`. It unintentionally inserted a second Feedback sidebar button plus a second Admin Key field. A local Chromium smoke test of that duplicate panel passed with mock API data, but that does **not** validate or justify the duplicate design. The screenshots/artifact from the older build are **deprecated**.

**Corrected implementation:**

- `sandbox/feedback-dashboard-staging-adapter.mjs` now verifies the exact existing native Feedback page and external script anchors, refuses a duplicate `#feedback` panel, and **only** updates the existing warning text to describe both Feedback and Appeal sender UserIds as *unverified claims*.
- No sidebar button, new password field, extra fetch request, moderator control or replacement UI is injected.
- `sandbox/feedback-dashboard-staging-adapter.test.mjs` explicitly guards preservation of existing navigation, Admin Key unlock and editor.
- `.github/workflows/feedback-dashboard-preview.yml` rebuilds a review-only immutable-source ZIP and rejects duplicate Feedback navigation.

**Still open for UI functionality:** The server's admin case API already selects `claimed_user_id`, but an earlier server-side embedded admin-console implementation rendered that field only when `kind === 'appeal'`. The authoritative deployed Pages Functions JavaScript for `/__asc1649/feedback-appeal.js` has not yet been recovered and reviewed. Therefore **do not claim that the native STAGING Pages Dashboard already displays an Unverified UserId for ordinary Feedback**. That rendering change must be applied to the original Admin case-detail function, preserving its existing UI and authorization.

A Pages Direct Upload needs proper asset-upload authorization. No Pages deployment was attempted, and Production remains untouched.

## 3. Deployment blocker and next release gate

Cloudflare Pages Direct Upload asset API currently requires a separate upload JWT. The connected Cloudflare API session returned HTTP **403 Authorization failed** for `POST /pages/assets/check-missing`, and its available request API does not allow us to supply the Pages upload JWT as the required Authorization header.

**Do not bypass this authorization check or blindly replace the current Dashboard project.** The original Pages deployment (and Production Dashboard) remain unchanged.

Before a real Dashboard deploy:
1. Use an authorized Pages Direct Upload workflow, or restore an authoritative Dashboard source-controlled build with a sanctioned deployment credential. Verify the exact preview UX on Android and desktop, including Cloudflare Access / CORS for a new preview origin.
2. Review Admin Key handling, API error handling and the fact that Username/Nickname are unavailable with the current backend response.
3. Before Production, complete independent Production D1 Backup & Restore verification and have a rollback plan. Production release still requires explicit owner approval.

**No changes were made to Production Worker, Production Pages or Production D1.**
