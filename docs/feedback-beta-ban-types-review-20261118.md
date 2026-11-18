# ArcScriptCenter — Ban category / Feedback Beta user identification (2026-11-18)

**Status: STAGING UI patch + admin classification module prepared, 6/6 local Node QA PASS. REVIEW ONLY. Not deployed. Production unchanged.**

## Owner request
1. Rename the native Arcsen Settings category **Feedback & Appeal** to **Feedback & Appeal (Beta Feature)**.
2. In the existing Admin Dashboard Ban System, show explicit **Banned** and **Temporary Banned** labels; both may lead to a **private Violation** notice in Arcsen once independently verified server-to-Roblox-account linking is implemented.
3. Make staff able to tell **which UserId was banned and who should be unbanned**, without conflating anonymous Feedback with ban records.

## Verified current implementation
- The existing `/api/v1/admin/bans` GET already returns GitHub-managed entries with `userId`, optional `username`, `reason`, `description`, `startAt`, `expiresAt`. STAGING endpoint deliberately rejects writes (403). Do not create a new ban database or claim STAGING can write bans.
- Existing `activeBanFor` treats `expiresAt==''` as permanent; non-empty `expiresAt` is a future ICT expiration; expired and scheduled restrictions should not display as active.
- `claimed_user_id` in a Feedback/Appeal is user-supplied and *unverified*. Old anonymous Feedback cases cannot be retroactively linked to a Roblox account. Ban lookup and unban decisions should use admin-managed ban entries and an independently verified principal, not an arbitrary claimed UserId.
- Native Arcsen UIs 7.3.49 currently labels optional UserId sharing `OFF (unverified)` by default. Preserve consent; do not silently change OFF to ON.
- Existing account-bound Violation renderer is intentionally private and dormant until a server-verified account binding exists. The signed UI policy currently has `identityVerified=false` and must not be used as proof.

## Prepared local ChatGPT artifacts
- Full **Arcsen UIs 7.3.50** Luau + unified v7.3.49→7.3.50 patch (exact replay verified).
- Rename category; explain that anonymous feedback cannot be tied to a Roblox profile; keep optional UserId OFF.
- The dormant, authenticated-only Violation renderer recognizes `banType='banned'` and `banType='temporary_banned'` with server-issued expiry in UTC; still refuses to display without `identityVerified=true` *from a trusted backend* and authenticated notice ID, reason, and moderator message.
- Pure Admin-side classification/helper `arcscriptcenter-ban-types-staging.mjs` and `.test.mjs`: 6/6 Node unit tests pass for active permanent, temporary, expired, scheduled, bad dates, mismatched identity, missing notice, and eligible verified notice.
- Neither generated patch nor helper has been automatically deployed or merged into the live Cloudflare Pages bundle.

## Exact admin UX to integrate (existing Ban List)
Use the existing authenticated `banRender()` and the current `GET /api/v1/admin/bans`. Add a text badge beside each existing UserId/Username:
- empty `expiresAt`, current active ban → **Banned**
- future nonempty `expiresAt` and already started → **Temporary Banned** + 'Until YYYY-MM-DD HH:mm ICT'
- elapsed expiry → **Expired**
- future `startAt` → **Scheduled**

Do not create a duplicate Admin Unlock form, route, or separate website. Keep Admin-only list private. The separate **User's Case** view should group entries by case-claimed ID and always mark that claim unverified.

## Violation link (not live)
A *new* user-facing actual Ban Notice needs an authenticated server-side Roblox principal, a staff-issued notice ID bound to that exact subject, ban type, public reason/moderator message and, for temporary bans, expiration timestamp. The client must never create Violation notices solely from its own `LocalPlayer.UserId` or by querying any arbitrary claimed UserId. A ban expiring should be server-enforced; a UI timestamp is not authority.

## Release guard
The STAGING Pages site's prior outage occurred when a review-only source ZIP was deployed instead of the full native Pages bundle, removing `index.html` and Pages Functions. Official rollback restored the previous canonical site. **Never upload these review-only files as the live Pages site.** Native Pages source must be obtained and integrated in place before any STAGING preview or deployment; keep canonical deployment unchanged. No Production modifications.

## Remaining acceptance
- Roblox phone UI visual check for v7.3.50; Violation ban types only with authenticated notice (server integration pending).
- Integrate Admin Ban badge into actual native Pages source, retaining original auth/session and all assets, then verify on a noncanonical STAGING preview and validate admin lock/logout.
- Separate server-verified identity/notice linkage, temporary expiry behavior, and authorized unban audit before release.
