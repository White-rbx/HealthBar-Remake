# ArcScriptCenter — Stage 16.70: Access-Protected Admin Feedback & Appeal Notifications

Date: 2026-11-15 (Asia/Bangkok)
Status: **Sandbox deployed; server-side query + synthetic D1 checks PASS; manual authorized browser UI checks pending.**
Production: **NO-GO**.

## User feature request

When a user submits a new Feedback or Appeal, show an admin-side notification.

This stage implements a **private admin page with in-page alerts** and **opt-in browser notifications while the page is open**. It does not offer email, Discord/Telegram, SMS, mobile push, or closed-browser notifications; those require a separate approved destination and infrastructure. No external notification destination is configured.

## Sandbox Worker deployment

- Worker: `arcscriptcenter-merge-sandbox-1658`.
- Version: `0.5.74.0-admin-feedback-notifications-sandbox`.
- Version ID: `1bbc90e8-c251-4995-a339-56342f636305`.
- Deployment ID: `d465248f-8a9f-4103-9bf8-40e5a724aefd`.
- Traffic: **100% sandbox Worker only**.
- Previous Sandbox version for rollback: `c23843e8-f6bb-4f2f-a254-cf0424070a67`.
- All **eight existing binding names/types** inherited. Secret values were not read, displayed, committed or copied. Production and Staging Workers/D1 were untouched.

### Protected Admin Page

`GET https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1670/admin-notifications`

Provides:

- Existing Admin Key input; kept **only in page JavaScript memory**, cleared from the input after Connect and cleared from memory on Disconnect. Never persisted to `localStorage`, Worker D1, GitHub or the URL.
- Checks new notifications every **20 seconds** while the page is running; manual **Check Now** also available.
- In-page toast for newly submitted **Feedback** or **Appeal**.
- Optional browser notification via user gesture (Enable Browser Notification). Not guaranteed on all mobile browsers; in-page alerts are always shown.
- Local-only **Test Local Notification** control, which does not create a case or write D1.
- A list of recent submission metadata (type + timestamp). No message text, personal information, receipt, private/admin notes or claimed Roblox UserId is included.
- Only the numeric last processed event ID is saved in browser `localStorage` for session-to-session de-duplication. On first connection, recent events appear in the list without replaying old alerts; on later connections, unseen events are surfaced if still present in the server-side event feed.
- If more than 50 events arrive while disconnected, API returns `hasMore` and the UI can page up to eight batches per check. Very high backlogs may need additional checks.
- Disconnect clears the in-memory Admin Key; API 401/403 disconnects the page. Page is protected by Cloudflare Access.

### Admin-only API

`GET /__stage1670/api/notifications?recent=1` (initial recent list)
`GET /__stage1670/api/notifications?after=<nonnegative event id>` (incremental notifications)

- Requires Worker-side `ctx.access`, exact protected Sandbox hostname, and a valid existing `X-Admin-Key` checked with `adminAuthenticated()`.
- Validates origin if present and validates numeric cursors.
- Response lists only `eventId`, `kind` and `createdAt` for `asc_feedback_history.event_type='submitted'`, joined to currently active, non-spam, non-removed Feedback/Appeal cases.
- Does not expose topic, complaint body, user ID, IP address, receipts, admin notes or Secrets.
- No database writes or schema migrations; all alert reads query pre-existing `asc_feedback_history` and `asc_feedback_cases`.
- No new permanent notification state table; the browser retains the numeric cursor, so deduplication is **per browser** rather than server-side across multiple admins/devices.

## Sandbox verification performed

1. Deployment and binding preflight PASS. Deployed version carries existing Stage16.64/16.66/16.67 routes unchanged.
2. Worker source read-back PASS: notification routes, Access checks, Admin Key checks, metadata-only SQL and no D1 mutations.
3. D1 synthetic fixture test (Sandbox only) PASS:
   - Two clearly marked synthetic cases (one Feedback, one Appeal) generated corresponding submitted history events.
   - The exact notification query found both kinds in chronological event order.
   - A subsequently soft-removed synthetic Feedback was excluded from new-alert results, and then the Appeal was also excluded after soft removal.
   - `PRAGMA quick_check` returned `ok`.
   - Exact synthetic rows and their history were removed; post-cleanup remaining synthetic cases = **0**, orphan history = **0**.
4. Actual authenticated Admin browser tests remain **PENDING**. No admin password/secret was retrieved by the assistant to perform these tests. Do not call the UI E2E test passed until the user confirms.

## Safe manual browser checks

1. Open the protected notification page after Cloudflare Access authentication.
2. Enter your existing Admin Key **locally in that page only**, not in ChatGPT or screenshots.
3. Press **Connect**. The status should indicate Connected and show recent events if any.
4. Press **Test Local Notification**. An in-page toast should appear. Optionally press **Enable Browser Notification**; this prompts browser permission, where supported.
5. Press **Check Now**, then **Disconnect**. Disconnect should erase the key from page memory.
6. If desirable, use a separate manually authorized genuine Feedback test to confirm arrival in real polling, and clean only the synthetic Sandbox records afterward.

**Caveats:** The page polls while open, so notifications stop if it is closed, frozen or offline. It is not a push service. Turnstile and Admin Key requirements remain unchanged. The API intentionally does not notify about removed/spam-mail cases to avoid exposing cases withdrawn by the submitter.

## Release readiness

- [x] Sandbox Stage16.64 HTTP tests — 19/19, tester-confirmed.
- [x] Sandbox Stage16.66 Real Turnstile verifier — 4/4, tester-confirmed.
- [x] Sandbox Stage16.67 genuine Feedback/Appeal workflow — 11/11, tester-confirmed.
- [x] Stage16.68 Incognito Cloudflare Access login challenge, tester-confirmed.
- [x] Stage16.69 schema-only migration rehearsal in disposable D1, PASS.
- [x] Stage16.70 Admin notification feature deployed in Sandbox with synthetic server-side query test PASS.
- [ ] Stage16.70 authorized browser page/notifications/permission check.
- [ ] Separate disallowed-identity Cloudflare Access denial check.
- [ ] Independent Production backup/restore certification and Worker compatibility review.
- [ ] Full Arcsen and existing Admin UI integration test.
- [ ] Explicit Production release approval.

**Production NO-GO**.

Cloudflare references:
- https://developers.cloudflare.com/workers/configuration/cloudflare-access/
- https://developers.cloudflare.com/d1/reference/time-travel/
