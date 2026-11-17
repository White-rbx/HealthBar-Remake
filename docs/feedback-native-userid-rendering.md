# ArcScriptCenter — Existing Admin Dashboard, claimed UserId rendering

2026-11-17 · **Review candidate only: NOT deployed**.

## Source recovered

We recovered the owner's prior Library archive `ExperienceSettings_Stage16.54_Verified_Unlock_Staging_Candidate.zip`. It contains the native `feedback-appeal.js`, `feedback-appeal.css` and embedded Pages `_worker.js` sources that the previous GitHub branch lacked. **Verified against the immutable STAGING Pages Preview on 2026-11-17:** the deployed JavaScript and CSS bytes match the archived sources exactly (SHA-256 below). The deployed HTML also matches the candidate after reversing its single security-warning copy edit. The internal Pages `_worker.js` source cannot be fetched independently from the public preview; its archived version is still a deployment candidate, not proof of byte-for-byte deployed Worker equality.

The live STAGING Dashboard already has one `#feedback-appeal` page. The old, duplicated `#feedback` preview **must not be used**.

## Minimal change

Original Stage16.54 native case-detail JS only shows claimed ID when `c.kind==='appeal'`. The new one-line patch shows `Claimed Roblox UserId` for **both Feedback and Appeal** in the same existing detail UI. Feedback with no ID shows `Not provided (unverified)`. Identity is not authenticated by this metadata.

- `sandbox/feedback-native-userid-stage1654.patch`: reviewable one-line diff.
- `sandbox/feedback-native-userid-patcher.mjs`: strict source-anchored helper that updates the client JavaScript and its **exact matching embedded `MOD_SCRIPT`** in the Pages Worker. It aborts if the source signature, copy, routing or contents differ. No full private owner-authored source is committed to GitHub.
- `sandbox/feedback-native-userid-patcher.test.mjs`: synthetic fixtures exercising missing IDs, both case types, source drift, preserving Admin UI and denying identity-based privilege assumptions.
- The owner-ready **STAGING Candidate ZIP** is shared as a conversation attachment. It includes `deploy-candidate/index.html`, `acs-logo.png` and `_worker.js`, plus `source/feedback-appeal.js` and the original CSS, patch diff, checksums and release notes.

## Offline verification from the actual saved source

- `node --check feedback-appeal.js`: passed.
- `node --check _worker.js`: passed.
- Original Stage16.54 auth-state regression: passed 7 simulated flows.
- Stage16.50 Pages security regression: passed 20+ checks.
- Local headless Chromium mock on 390×844 and 1280×900: passed **three synthetic cases** (Feedback with UserId, Appeal with UserId, Feedback without UserId), unlock, native navigation, detail display, and Lock. Browser used stubbed API and a dummy key only. No live admin credentials or private cases accessed.
- Consolidated GitHub QA runs synthetic source-patcher tests and existing security regressions.

**LIVE PREVIEW READ-ONLY QA — PASSED:** The project default domain `arcscriptcenter-dashboard-staging.pages.dev` returned the SPA fallback HTML for the JS URL, but that is **NOT** the correct immutable STAGING Preview. The exact Preview deployment `https://416b162f.arcscriptcenter-dashboard-staging.pages.dev/` returns HTML, JS and CSS as HTTP 200 with their correct MIME types. Cloudflare Browser Run checked 390×844 mobile and 1280×900 desktop: one native Feedback page and sidebar item, zero duplicate pages, zero JavaScript page errors. An unauthenticated Admin API read was rejected HTTP 401. No Admin Key or case data was used.

| Source asset | Live SHA-256 | Archive match |
|---|---|---|
| `index.html` (unaltered native page) | `13d370b533b052f218883954e8a6115abc7f2230676a3fed16ca3f1be2f82bce` | Exact after reverting the candidate's warning copy |
| `/__asc1649/feedback-appeal.js` | `28853de16436acb3145259e2deba9a9cf5a24d4164659d6d8fa790df48736f24` | Exact Stage16.54 source |
| `/__asc1649/feedback-appeal.css` | `4e429fc23a981bfa1667ec1d89cfcaad8297cdcce0d00353d1e59b6da1f4f219` | Exact Stage16.54 source |

`sandbox/feedback-pages-preview-integrity.test.mjs` enforces these pinned public hashes in GitHub CI.

**Still untested:** a newly deployed patched Pages Preview and authenticated Admin end-to-end functionality. The current immutable Preview still runs the original **Appeal-only** UserId rendering. The patched STAGING Candidate ZIP remains **not deployed**.

## Release gating

1. Confirm the archived Pages `_worker.js` adapter remains compatible with the approved live Pages Functions routing; the deployed static JS, CSS and original HTML are now verified byte-for-byte.
2. Obtain valid, authorized Pages Direct Upload asset permission or a sanctioned source-control deployment; the connected Cloudflare Pages asset endpoint returned HTTP 403 previously. **No bypass.**
3. Deploy **preview/STAGING only** after explicit review, verify `/__asc1649/feedback-appeal.js` returns `text/javascript`, and smoke test mobile/desktop with real Admin permissions without exposing the Admin Key to chat or GitHub.
4. Preserve original Admin Key authorization, Spam Mail admin-only behavior, receipt-scoped case access, and no private Violation History from unverified identifiers.
5. Production requires backup/restore verification, rollback, and explicit owner approval. No Production or existing Pages deployment has been modified by this work.

The STAGING **API** Worker v41 is a separate previously deployed change that accepts optional sender UserId metadata for Feedback. This UI candidate does not deploy a new API Worker.
