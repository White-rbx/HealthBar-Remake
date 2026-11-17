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

## 2. Dashboard Pages — preview built, NOT deployed

- Existing Pages STAGING project: `arcscriptcenter-dashboard-staging`.
- Original latest preview deployment ID `416b162f-883f-4caa-b0ac-47d3f7458503` (source branch `stage16-54-verified-unlock`).
- The pinned original HTML had no Feedback navigation or panel.
- `sandbox/feedback-dashboard-staging-adapter.mjs` adds one **read-only** `Feedback & Appeal` tab using existing sidebar, panel styling and API base.
- Admin Case list uses existing protected `GET /api/v1/admin/feedback?status=` route and requires the real X-Admin-Key. All fields render through DOM `textContent`.
- The Admin Key lives only in page JavaScript memory with explicit Lock and ten-minute expiry. No credential in links, persistent storage or scripts.
- The UI displays **Claimed UserId: <value> (Unverified)**. Real Username/Nickname are **not** returned by current Admin API; UI honestly displays `Username / Nickname: Not provided by API` rather than fabricating a name.
- The Spam Mail filter is **admin-only**. No public Violation History or user's Appeal authority is added.

GitHub workflow `.github/workflows/feedback-dashboard-preview.yml` downloads the immutable public STAGING deployment via HTTPS, pins the exact HTTP response MD5 plus source anchors, creates a `dashboard-preview/index.html` + logo and uploads a ZIP artifact.

- GitHub Actions preview generation **PASSED**: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44084489098
- Release-track tests **PASSED**: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44084498245
- Preview ZIP artifact: `arcsen-feedback-dashboard-preview-review-only`.
- Output is a **review-only local HTML bundle**, not an active Cloudflare Pages release.

A first CI attempt incorrectly assumed the Cloudflare Pages **asset-store hash** equaled the raw HTTP response MD5. It failed closed; code was corrected to pin the actual HTTPS response digest, `4f04057ac9b3934356553499eab5cf9a`, together with the immutable deployment URL and expected source anchors. The final preview workflow passed.

## 3. Deployment blocker and next release gate

Cloudflare Pages Direct Upload asset API currently requires a separate upload JWT. The connected Cloudflare API session returned HTTP **403 Authorization failed** for `POST /pages/assets/check-missing`, and its available request API does not allow us to supply the Pages upload JWT as the required Authorization header.

**Do not bypass this authorization check or blindly replace the current Dashboard project.** The original Pages deployment (and Production Dashboard) remain unchanged.

Before a real Dashboard deploy:
1. Use an authorized Pages Direct Upload workflow, or restore an authoritative Dashboard source-controlled build with a sanctioned deployment credential. Verify the exact preview UX on Android and desktop, including Cloudflare Access / CORS for a new preview origin.
2. Review Admin Key handling, API error handling and the fact that Username/Nickname are unavailable with the current backend response.
3. Before Production, complete independent Production D1 Backup & Restore verification and have a rollback plan. Production release still requires explicit owner approval.

**No changes were made to Production Worker, Production Pages or Production D1.**
