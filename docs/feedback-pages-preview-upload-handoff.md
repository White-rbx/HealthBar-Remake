# ArcScriptCenter — Authorized STAGING Pages Preview Upload Handoff

Date: 2026-11-17. **Review-only; no Pages deployment or Production changes made in this pass.**

## Ready-to-upload bundle

The owner-facing chat artifact `ArcScriptCenter_Dashboard_STAGING_Pages_Preview_Ready.zip` contains exactly three **root-level** files:
- `index.html` — one original Feedback & Appeal page, warning copy clarified
- `acs-logo.png` — original logo
- `_worker.js` — original Pages Advanced Mode Worker with one native UserId rendering change

SHA-256 of zip: `c82c79abab38a3db2967d82ef248f417b3b4182540a6b1c37b8ab706a7c5cd4d`. The private owner-authored full source is deliberately NOT committed to GitHub.

`node --check` passed on the Pages Worker and embedded client JS. A Node runtime fixture invoked the actual bundle's `fetch` handler and verified exactly matching Feedback JS and CSS, correct `text/javascript`/`text/css` content types, no-cache and `nosniff`, a single original Feedback page, unchanged HTML, and both Feedback/Appeal UserId display (or `Not provided`).

## Actual STAGING Preview CORS security check (no real Admin Key)

Pinned Preview: https://416b162f.arcscriptcenter-dashboard-staging.pages.dev/

- Admin API request from that origin with **synthetic invalid** `X-Admin-Key` caused preflight `OPTIONS` → 204 with `Access-Control-Allow-Origin` set to the exact preview origin.
- Subsequent `GET` → **401 Unauthorized** with that origin authorized for CORS. Unauthorized access is denied, as intended; this does NOT prove that a real Admin Key works after a new Preview deploy.
- Source hash CI for pinned HTML/JS/CSS: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44099131249 — passed.
- The original pinned Preview is still **unpatched**. The candidate ZIP has not been deployed.

## Deployment route and safety

Cloudflare Pages supports dashboard Direct Upload for an Advanced Mode `_worker.js` file. The connected Cloudflare API can issue a short-lived Pages asset upload JWT, but the current connector's `cloudflare.request` operation has no custom request-headers parameter, so we cannot supply that JWT for the Pages asset upload endpoints. A prior unauthenticated asset call returned 403. **Do not bypass this restriction.**

To test the candidate through an authorized Cloudflare account, go to Workers & Pages → `arcscriptcenter-dashboard-staging` → Create deployment, **Preview**, select a **new non-production branch** such as `feedback-unverified-id-review-20261117`, and upload the **root-level ZIP**. STOP if the UI offers Production / `main` only. Never upload the multi-folder review ZIP.

After deployment check MIME and native UI on the **new** preview URL, verify the Admin API under a legitimate private Admin session (without publishing keys or case data), and verify no private Violation History lookup becomes possible through claimed UserId alone. A new preview hostname requires independent CORS verification; passing CORS on the older immutable preview does not automatically prove the new hostname is accepted.

**Production and its D1 remain untouched.** Production release requires approved backup/restore, rollback and owner authorization.

Official docs: https://developers.cloudflare.com/pages/get-started/direct-upload/
