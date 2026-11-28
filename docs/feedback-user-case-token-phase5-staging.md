# Feedback Phase 5 — Automatic Rejoin

Arcsen Preview v7.3.60 uses the server-issued User Case Token for read-only
Feedback recovery. Under **Settings → ArcScriptCenter → Feedback & Appeal →
Feedback**, use one of these paths:

- For new Feedback, turn on **Create/Attach after Feedback**, then submit.
- For an older case, use **Restore previous case (ID + Receipt)**, check its
  status, and confirm **Link Feedback to User Case Token**.

Turn on **Remember Token** to reuse the token on the next run. The first rejoin
request starts independently of verified account Case Delivery. **Refresh and
Check Server's case** can also fetch the linked cards. A restored card needs
its private Receipt for case management. An older case without a token link
needs its original Case ID and private Receipt once before rejoin can find it.

The local JSON contains the plaintext token when Remember is enabled. The
server stores only its hash. Disabling Remember removes the local file. Revoke
invalidates the shared token without removing any Feedback. Account claims
such as Roblox username and UserId never authorize Token Case access.

## Deployment

- STAGING only. The additive migration
  `migrations/feedback_user_case_token_STAGING_REVIEW_ONLY_20261120.sql`
  installed two tables and two indexes. It did not backfill case links.
- Cloudflare Worker version `78d736e3-4bde-4031-8a0b-38c4bd4e6888` includes the
  pinned original STAGING module and mounts the four token endpoints via
  `sandbox/feedback-user-case-token-router.mjs`. Existing routes still use
  the original Worker. The new quota binding applies independently to token
  endpoints. The Cloudflare rate limiter is scoped per edge location.
- Roll back Worker traffic to `666d7be4-78ea-43ee-9f63-92e5faac38b6` if needed.
  Keep the additive token tables in place so links survive a rollback.
  Use the existing Receipt flow while token sync is unavailable.

## Verification

- Luau compiled the complete Arcsen Preview. The focused Node tests cover
  Restricted Mode, Arcsen state, the SQLite migration, and Token Case paths.
- An isolated Cloudflare Worker and D1 returned 32 linked synthetic cases
  across two pages, including a Denied case and its public reviewer note.
  Checked concurrent issuance, token isolation, bad Receipts, relinking
  after revoke, and rejection of revoked tokens. Removed both QA resources.
- Live STAGING HTTP passed legacy health, synthetic Feedback submit and
  Receipt lookup, explicit token consent, a fresh token-only case lookup,
  revoke, and Receipt-authorized removal of the synthetic case.
- Mobile acceptance remains open. Run the [STAGING Loader Preview](https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua),
  link a STAGING Feedback case, enable Remember, then leave and rejoin.
  The case should reappear in its status section without entering its Receipt.
