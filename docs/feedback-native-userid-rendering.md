# ArcScriptCenter — Existing Admin Dashboard, claimed UserId rendering

2026-11-17 · **Review candidate only: NOT deployed**.

## Source recovered

We recovered the owner's prior Library archive `ExperienceSettings_Stage16.54_Verified_Unlock_Staging_Candidate.zip`. It contains the exact native `feedback-appeal.js`, `feedback-appeal.css` and embedded Pages `_worker.js` sources that the previous GitHub branch lacked. This is a saved **Stage16.54 review candidate**, NOT proof that those source bytes equal the latest hosted Pages Functions deployment.

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

**Not tested:** live Admin API from Pages after deploying this candidate. The unauthenticated Cloudflare Browser Run GET of `/__asc1649/feedback-appeal.js` on the hosted STAGING domain returned HTTP 200 **text/html**, not JS. This suggests that the route may not currently serve the expected asset; a properly authorized Pages Preview must independently confirm HTTP response status, Content-Type and client-side functionality before release.

## Release gating

1. Verify the saved Stage16.54 source/candidate matches the approved live Pages Functions variant and that the protected Pages HTML has not drifted.
2. Obtain valid, authorized Pages Direct Upload asset permission or a sanctioned source-control deployment; the connected Cloudflare Pages asset endpoint returned HTTP 403 previously. **No bypass.**
3. Deploy **preview/STAGING only** after explicit review, verify `/__asc1649/feedback-appeal.js` returns `text/javascript`, and smoke test mobile/desktop with real Admin permissions without exposing the Admin Key to chat or GitHub.
4. Preserve original Admin Key authorization, Spam Mail admin-only behavior, receipt-scoped case access, and no private Violation History from unverified identifiers.
5. Production requires backup/restore verification, rollback, and explicit owner approval. No Production or existing Pages deployment has been modified by this work.

The STAGING **API** Worker v41 is a separate previously deployed change that accepts optional sender UserId metadata for Feedback. This UI candidate does not deploy a new API Worker.
