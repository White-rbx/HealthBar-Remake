# ArcScriptCenter User's Case / Unknown Trash — LIVE STAGING PREVIEW (2026-11-18)

**Status:** Noncanonical STAGING Preview deployed and live HTTP smoke passed. Browser authenticated UI acceptance still pending. Production and canonical STAGING remain unchanged.

## Open the new Preview using its allowlisted branch URL

https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#feedback-appeal

Unique immutable deployment: https://da89f55b.arcscriptcenter-dashboard-staging.pages.dev/  
Deployment: da89f55b-4c3b-4bf0-b1ce-a10341dca6ab; environment preview; branch stage16-54-verified-unlock; status success; uses_functions true.

**IMPORTANT:** Admin APIs allow the branch alias origin above, but not the immutable `da89f55b` origin. To Unlock and use private Admin APIs in browser use the **branch alias URL**, not the immutable URL or the older `fc001ca0` attempt.

## What was integrated

- Native current canonical Pages static assets reused by exact Cloudflare stored hashes: index.html b388e6140f1ade679f99046116732ecb, acs-logo.png 4b25ba35fd0d822ee53b65413f589a48.
- Complete advanced-mode Pages _worker.js built from original 17 November full Pages package, modified to inject *only* User's Case panel into the **already-present** native Feedback & Appeal page, preserving existing native page, sidebar, Ban Management, Admin Unlock and other features.
- Buttons: Load User's Case, view Unknown / Unlinked cases, Move Unknown Case To Trash with explicit confirmation, View Trash, Restore before 30-day expiry, and return to original Admin Case Review.
- Original Admin Key stays memory-only, reused through Admin API / Service Binding. No key in GitHub, URL, browser storage or ZIP.
- Username search currently uses the existing Ban List username when present and UserId. **Universal Roblox Display Name search is not live in this Preview**, although a separate review-only directory source exists in this PR.
- Existing Admin Trash Gateway already deployed: arcscriptcenter-trash-admin-staging. Dedicated hourly Cron Worker already deployed: arcscriptcenter-trash-purge-staging.

## Real live test history

First Preview fc001ca0 created, but real HTTP smoke run 44317609701 failed: canonical current HTML already contained Feedback & Appeal, and HTMLRewriter's old duplicate-page prevention skipped User's Case insertion entirely (X-ASC1649-Integration: skipped-already-installed). Fixed by injecting *only the User's Case section* inside original Feedback layout. Second Preview da89f55b deployed successfully.

**GitHub Actions run SUCCESS:** https://github.com/White-rbx/HealthBar-Remake/actions/runs/44318266506

Checks included:
- Branch Preview HTML has User's Case, Load, Trash and original existing pages; exactly one new User's Case.
- Native Feedback JavaScript and CSS route 200 and proper MIME.
- PNG logo asset accessible.
- Existing Admin API and Trash API CORS OPTIONS 204 for allowed branch alias.
- Unauthorized GET/POST denied 401; immutable deployment origin denied 403.
- Source tested by Node --check and SHA256.
- Final native Pages Worker complete source checked into this Draft PR at sandbox/pages-native-users-case-trash-preview-20261118.js, with SHA256 d1acc7066a1b00f78ebe0dc78df5fe9287a8500cbcb5abe91b6b61b345931609.

## Final Cloudflare read-only audit

- Preview: da89f55b, success, functions enabled, both original assets present.
- Canonical STAGING Pages: 3a36ea6d-d867-45a0-931d-87f6df64ed8c, unchanged.
- Original STAGING API Worker: 666d7be4-78ea-43ee-9f63-92e5faac38b6, unchanged.
- STAGING D1: 7 cases total, 3 missing claimed UserId, 0 removed, 0 in Trash.
- Scheduled Trash GC: 0 * * * *.
- No real cases were moved or deleted. Production untouched.

## Remaining acceptance

The owner should open **branch alias** on mobile, enter Admin Key **in the website only** and tap Unlock; check User's Case > Load User's Case, the Unknown / Unlinked group, View Trash (empty), open original Admin Review and Lock/reload. Do not move any existing real unlinked case merely to test UI. Positive authenticated move/restore should first be exercised with a synthetic STAGING feedback case that was deliberately created for testing. Don't promote canonical STAGING or merge Draft PR until this acceptance. Step 2/4 remains open for interactive acceptance and full name enrichment.
