# ArcScriptCenter — Feedback & Appeal consolidated release track

Date: 2026-11-17. Status: **Review-ready sandbox code and GitHub QA; not deployed.**

## Why no more stage-by-stage PR churn

Keep the next work in three cohesive workstreams under ONE review track: security decisions, Arcsen native compatibility, and final QA. Do not restart the OAuth/Pairing pipeline as a prerequisite for ordinary Feedback. Use existing tested features instead of re-creating them.

### 1. Security finalization: separate Feedback from sensitive account data

- General Feedback can be submitted under the project Rules, without checking a Roblox account's age or requiring Roblox OAuth. The existing browser production template uses genuine Turnstile before submission, and server-side anti-spam remains mandatory.
- The existing STAGING native Arcsen transport POSTs to `/api/v1/feedback/submit` via the fixed staging API. Its two-tap confirmation and session-only receipts remain unchanged. Do not suggest native Luau can solve browser Turnstile; these are distinct transports.
- An Appeal **claim** can be submitted via the existing receipt workflow; a `claimedUserId` from LocalPlayer is NOT proof of account ownership.
- Only the case's valid private Case ID + Receipt authorize that case's status/edit/remove under server-side rules. Never use a receipt to read a Roblox account's entire Violation History.
- Private Violation data and moderator actions require independently verified Roblox identity and server permission checks. An OAuth app creation eligibility blocker must not be bypassed.
- `Spam Mail` stays admin-only. Appeal remains nested under Violation in the Arcsen user UI. UI default language is English.

### 2. Arcsen integration: preserve the actual developer-designed native UI

Reviewed the existing **Arcsen UIs v7.3.43, Stage16.79**, from the user's prior Library artifact. The source already implements:

- The original `Settings → ArcScriptCenter → Feedback & Appeal` native sections (Rules, Feedback, conditional Violation).
- Sender preview with `DisplayName`, `@Username`, and `UserId`, visibly labeled as **unverified client data**.
- Native STAGING Feedback drafts, two-tap submission, private receipt session storage, case lookup and receipt-authorized editing/removal.
- A deliberately HIDDEN Violation category unless an authenticated, account-bound violation actually exists. User-designed nested Appeal is preserved.
- **Browser Bridge deliberately removed in Stage16.77.** Do not add a new browser-redirect button without the designer asking for it; the user explicitly preferred the native UI.

Therefore no new Arcsen GUI has been fabricated, replaced or deployed by this PR. It is safer to preserve the already working native UI and close its server-side verification gaps separately than to create a third parallel Feedback interface.

**Important outstanding issue:** Sender preview is still client-supplied. Current STAGING `fcSubmit` inspection showed `claimedUserId` but no `username`, `nickname` or `displayName` fields in the submit function. The preview does not establish an admin-verifiable sender identity. Do not claim it does. Any future sender label in an Admin Dashboard must be clearly marked `Unverified sender` until independently verified.

### 3. Final testing: one consolidated CI gate

Changed in this PR:

- Completed English localization of **dynamic JavaScript messages** in `sandbox/production-feedback-appeal-form.js` and `sandbox/stage16-76-arcsen-bridge.js`. HTML was previously translated, but 31–32 Thai status/error lines were still in JS.
- Added `sandbox/feedback-release-contract.mjs` and `.test.mjs` to lock in open anonymous Feedback, receipt-only case management, correct staging/production route segregation, no account-age gate, English UI, and private violation rules.
- Added `.github/workflows/feedback-appeal-release-track.yml`, running the existing synthetic browser Feedback form end-to-end tests, route and security gates, English checks, Stage16.83 Pairing and Stage16.87 trust-boundary regressions.

**Read-only Cloudflare check:** Existing `arcscriptcenter-staging` D1 contains `asc_feedback_cases` and `asc_violation_notices`. No table rows, private receipts, user identities or secrets were retrieved.

## Important release gates (kept short)

1. **Green GitHub Actions CI** with original browser contract tests and security regressions.
2. **Android native Arcsen UX** user smoke test (Feedback, Case ID + Receipt status, Edit/Remove in STAGING; confirm sender preview is labeled unverified). Do not claim device validation from offline tests.
3. **STAGING-backed feedback end-to-end test**, with synthetic records only, and exact receipt-based cleanup. Turnstile browser flow must be tested in an actual authorized browser by the owner.
4. **Private Violation/Appeal authorization** stays hidden until real server proof; do not accidentally unlock it when ordinary Feedback works.
5. **Production NO-GO** until independent backup/restore verification, full security review, and explicit owner approval. Production/staging API and database were **not modified** by this PR.

Do not count Draft PRs as an actual release. The next user-visible goal is a functioning, owner-tested Arcsen Feedback journey, not a new sequence of Stage numbers.