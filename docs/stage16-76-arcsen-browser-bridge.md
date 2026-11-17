# ArcScriptCenter — Arcsen Client Browser Bridge (Stage 16.76 Sandbox)

Date: 2026-11-17 (Asia/Bangkok)
Status: **CODE DEPLOYED TO ISOLATED SANDBOX. BROWSER AND IN-GAME ACCEPTANCE PENDING.**
Production: **NO-GO**, unchanged.

## Objective and context

Connect the existing Luau Arcsen UI to real Turnstile testing **without** injecting secrets, simulating browser challenges in an executor, rebuilding the developer's UI, or promoting to Production.

Read the source of the previously saved **Arcsen UIs v7.3.39** (the most recent accessible client artifact, 16,247 lines / 930KB) before changing anything. Existing user-side structure is preserved:
- `Arcsen → Settings → ArcScriptCenter → Feedback & Appeal`.
- `Appeal` stays nested in `Violation`, preserving the developer-designed 350px viewport.
- `Spam Mail` is Admin-only, never a user-facing section.
- Existing Luau STAGING submit / receipt / status / edit / remove flows remain untouched.

## Implementation

### Arcsen client v7.3.40 (downloadable in the related ChatGPT answer)

Derived from `Arcsen_v7.3.39_Moderator_History_Filter_Staging.lua`:
- UI version updated to `UIs 7.3.40` with a Stage16.76 changelog entry.
- New `o()` row **Browser Turnstile (Sandbox)** inside existing Feedback & Appeal panel, with an expandable explanation and **Copy protected Browser URL** button.
- The URL is public route metadata only and is copied by explicit user interaction; no token, receipt, identity, secret, or Access cookie is copied by this action.
- Integration accessible via `loc.API.ArcScriptCenterBrowserBridgeURL` and `loc.API.CopyArcScriptCenterBrowserBridgeURL`.
- New local variables are scoped to a `do ... end` block to minimize pressure on the large Luau module's local count.
- Existing STAGING submission buttons are **still STAGING** and do not bypass Turnstile; user must open browser to run genuine Turnstile.
- No new `ScreenGui` or replacement of the custom Violation/Appeal UI.

Client file has undergone static textual/patch consistency checks, **not** Roblox mobile execution. Do not mark in-game UX PASS before a real device test.

### Sandbox browser front-end

GitHub source:
- `sandbox/stage16-76-arcsen-bridge.html`
- `sandbox/stage16-76-arcsen-bridge.js`

Adapted from existing `sandbox/production-feedback-appeal-form.{html,js}` with explicit Sandbox labeling:
- Access-protected `GET /__stage1676/arcsen-bridge`, static JavaScript `GET /__stage1676/bridge.js`.
- Actual Managed Turnstile runs in Chrome and generates a genuine single-use token bound to action `feedback_submit` or `appeal_submit`.
- Submit explicitly confirms before creating a row in the **isolated Sandbox D1**; uses existing `POST /__stage1667/submit` with server-controlled real Siteverify checks for origin, action and token.
- Same-origin, cookie-authenticated requests are required for Cloudflare Access.
- Existing receipt-scoped status, edit and remove are reused through `/api/v1/feedback/status` and `/api/v1/feedback/manage`.
- Browser form uses a **synthetic claimed Roblox UserId** for Appeal (test data only; does not prove identity).
- Receipt stays in the current browser until manually copied; no receipt/token in URL, browser localStorage, analytics or GitHub.
- Test text only; do **not** put real account IDs, credentials or personal details into Sandbox.
- Browser JS compiled with JavaScript syntax parser (PASS) and static route/config assertions passed.
- HTTP pages could not be verified from an external unauthenticated browser session by the assistant. The user's Cloudflare Access-approved browser must test them.

### Cloudflare Worker deployment

- Worker: `arcscriptcenter-merge-sandbox-1658`.
- Code version: `0.5.80.0-arcsen-browser-bridge-sandbox`.
- New version ID: `bc4e8484-8901-4e0a-9d19-a20120f59ac8`.
- Deployment ID: `cad10b86-cefb-4ec2-ad14-381a7eeb9634`.
- Traffic: **100% Sandbox only**.
- Previous rollback version: `1c6ce118-27b7-40c4-9c0d-2b8c6d3a4776` (Stage16.75).
- Worker bindings: **12/12 preserved** through inheritance, Secret values never read.
- Existing Cron `*/5 * * * *` is unchanged; `scheduled(...)` handler preserved.
- Existing Stage16.67 genuine Siteverify POST flow preserved. No additional mutating API endpoint was created, only two Access-protected GET routes.
- Worker Cloudflare compilation passed when version upload succeeded. GET read-back confirmed the active version, added routes, inherited bindings, cron, and isolated D1.
- Production Worker, Production D1, Staging Worker and Staging D1 were not changed.

## Manual acceptance procedure (Android + Arcsen)

1. Load **Arcsen 7.3.40** into the private/test environment only.
2. Open `Settings → ArcScriptCenter → Feedback & Appeal → Browser Turnstile (Sandbox)`.
3. Tap **Copy protected Browser URL**; in Android Chrome open:
   `https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1676/arcsen-bridge`.
4. Confirm Cloudflare Access login is required when not already authenticated, and only the allowed tester can enter.
5. Run **one** synthetic Feedback first, using a topic of 3–50 chars and description of 50–1500 chars. Complete Turnstile and explicitly confirm.
6. Expected: HTTP 201, browser displays private Case ID + Receipt; keep both private.
7. Test Status (200), Edit while Reviewing (200), Remove (200), then status with removed receipt (404).
8. Repeat with a synthetic Appeal if necessary (50–5000 description chars); browser uses a fabricated UserId for the sandbox.
9. Verify the Arcsen UI scroll sizing and that the 350px nested Violation UI and STAGING case-management flows remain unchanged.
10. After testing, inspect Sandbox D1 for synthetic leftovers and clean them using **exact identified rows only**, with Time Travel bookmark preflight. Do not blindly delete quota rows.

Status codes are **expected**, not actual new-device test outcomes yet. If the browser fails, report only endpoint, status and non-sensitive error.

## Gates before Production

- [x] Stage16.64 previous Sandbox tests (19/19 user confirmed).
- [x] Worker compiled/deployed; 12 inherited bindings, Cron preserved.
- [x] Browser bridge assets and v7.3.40 client patch prepared.
- [ ] Android Chrome genuine Turnstile browser-bridge smoke test.
- [ ] Arcsen 7.3.40 in-game UI and navigation on real device.
- [ ] Real approval/Access denial and other previously tracked security gates.
- [ ] Independent Production backup restore verification.
- [ ] Production release signoff.

**Do not promote this Sandbox-only browser integration to Production without completing all release gates.**
