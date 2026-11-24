# arcscriptcenter-login — three-page STAGING UI revision (2026-11-24)

## Requested layout and cause

The previous `sandbox/ESLogin.lua` reused the original **Username** and **Password** labels/fields as **Pairing code** and **Sign-in status**. The QA user requested the original field layout back and a website called `arcscriptcenter-login` with three pages:

1. **Login page** — `/login` (and `/` alias): branded landing page with a Sign in entry link.
2. **Sign In page** — `/signin`: original Username/Password layout preview, plus the actual Passkey Sign In action. Register and Recovery remain subviews `/signin#register` and `/signin#recover`.
3. **MyAccount** — `/myaccount`: displays real identity only following a successful server-side account Session check. A direct unauthenticated `/myaccount` URL redirects to Sign In; never trust a query string, localStorage value or client-side username for identity.

## Implementation

- `sandbox/ESLogin.lua`: restores visible **Username** and **Password** labels and original field components; adds separate **PairingInput** and **SignInStatus** controls so pairing never overwrites credentials or labels. Responsive centering and constraints prevent narrow Android clipping. Existing Login handoff, copy/open-link fallback, Remember and close **X** cancellation are preserved.
- `sandbox/asc-account/passkey-page.mjs`: presents branded three-page website, including accessible navigation. Website name is `arcscriptcenter-login` in the title and heading. The Username/Password UI is a **disabled layout preview only**.
- `sandbox/asc-account/passkey-client.js` and identical bundled `.txt`: browser routing via History API while maintaining Passkey registration, authentication, backup credential, one-time recovery code, ESLogin pairing and logout. MyAccount remains scoped to the existing server-issued, HttpOnly Account Session.
- `sandbox/asc-account/passkey-static.mjs`: serves only the explicitly allowlisted `/`, `/login`, `/signin`, `/myaccount` HTML routes with the existing strict noindex and CSP headers.
- `sandbox/asc-account/passkey-style.css` and identical bundled `.txt`: mobile-friendly three-page navigation and clearly disabled password widgets.
- `sandbox/asc-account/login-pages.test.mjs`: tests all three pages, fail-closed MyAccount deep links, navigation with a verified synthetic Account Session, the disabled Password presentation and identical bundled assets.
- `sandbox/asc-account/workerd-passkey.test.mjs` and `sandbox/ban-v2-native-luau.test.mjs`: corresponding Worker and native Luau regressions.

## Security boundaries

**No Password login is activated.** The old legacy password gateway is intentionally disabled in Passkey mode and is not verified as viable on Cloudflare Workers Free with its secure scrypt cost. Do not collect or submit actual passwords from the Roblox client. Username/Password textboxes in ESLogin are read-only and the browser's legacy password widgets are disabled. Sign In through Passkey is the sole proposed interactive method in isolated QA. Do not imply the password fields are presently functional.

The public-facing site hostname/project `arcscriptcenter-login` is **not yet provisioned or deployed**; this update defines the site name and routes inside the GitHub STAGING Account QA candidate. Live Account QA still serves its locked provisioning response until explicitly approved isolated deployment, D1 and Access verification, correct fixed Origin/RP ID and a separate Turnstile configuration are ready. In particular, the old immutable Cloudflare Worker Version 11 is not silently replaced by this change.

### Immutable bundle note

`qa-undeployed-version-upload.mjs` is pinned to the previously verified 900711-byte Worker from source commit `2ac41e90` (Cloudflare Version 11) and must **not** have its expected digest or size updated just to accommodate new website code. The new source bundle will be rejected by that uploader. Consolidated CI instead checks that non-pinned builds fail closed; a newly reviewed candidate needs its own pinned rollout approval and deployment gate.

**STAGING ONLY**. No Production changes, no public login/registration, no Cloudflare D1 mutation, no Merge of PR #16.
