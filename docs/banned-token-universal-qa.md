# Universal BANNEDTOKEN QA

The universal preview uses the executor's `request`, `http_request`,
`syn.request`, `http.request` or `getgenv().request`. Roblox
`HttpService` is used for JSON only. The Universal path has no dependency
on a Roblox server Script, ReplicatedStorage remote or experience ownership.
The separately selected `roblox_server` preview remains available for the
older owned-experience QA flow.

## First link and return visits

1. An authorized ArcScriptCenter operator verifies the recipient independently
   and confirms that the case is already linked to that Roblox account in
   verified history. For a future self-service flow, an official Roblox OAuth
   browser session can establish the stable subject and verified account
   username before issuing the same enrollment. No OAuth app is configured by
   this QA rollout.
2. Server-side moderation invokes `issueCaseEnrollment(db, {subject, noticeId,
   username})` from `banned-token-universal-qa-worker.mjs` and delivers the
   one-time code privately to that verified recipient. This helper is not
   mounted as an HTTP route. The code expires after 15 minutes and can be
   exchanged once. The code is different from the displayed BANNEDTOKEN
   reference and from USERCASETOKEN.
3. In Arcsen → Settings → ArcScriptCenter, paste the one-time code and press
   **Link private case**. Choose **Remember private case** before linking to
   restore it automatically from the same executor's local files on later
   runs. Without that choice, the scoped session stays in memory. Access is
   limited to one verified case for up to 30 days and can be revoked using
   **Disconnect private case**. A remembered session's local bearer can be
   read by software with access to that executor's filesystem.
4. The Worker rechecks expiry and current case ownership on every request.
   The submitted client UserId is used only on the public status route.
   Appeal writes also check the active grant and appeal eligibility atomically.
   Revocation, expiry or a case ownership change hides private data. Approved
   Appeals remain closed. A public restriction can still display if the
   private request times out or is rejected.

## Base32 token verification

1. Worker checks the independent Private Case Session against the current
   D1 owner and case scope before opening the case's server-side envelope.
2. The envelope is `BANNTOKEN2_<Base32 payload>.<Base32 HMAC-SHA256>`, using
   canonical unpadded Base32. It contains the verified Roblox UserId,
   username snapshot, notice ID, explicit linked ban revision, a
   128-bit random secret, and an expiry. Base32 is an encoding. HMAC
   verifies integrity. The case session and current D1 owner grant access.
3. D1 retains only an AES-GCM sealed copy and SHA-256 hashes for the
   current token and case secret. The HMAC key and AES key are derived
   separately from the Worker-only secret. The Worker verifies signature,
   canonical form, D1 user and username snapshot, secret hash, expiry and
   revision. A mismatch returns no private data.
4. A verified case session can rotate a previously intact envelope after
   24 hours or after a moderation link changes. Compare-and-swap prevents
   racing issuances from overwriting each other. The current D1 hash
   rejects replacement by an older envelope. There is no endpoint that
   accepts a BANNEDTOKEN as a credential.
5. Roblox UserId remains stable across renames. Existing tokens carry a
   verified username snapshot. The next rotation can take a newer
   verified username from the case session without changing ownership.
6. The Client receives only `••••XX`. WarningUI adds it only if the
   authorized case matches the current ban revision. Historical notices
   remain available from a verified session when they are unrelated to a
   newer active ban, without attaching a stale reference to that ban.
   Appeal creation atomically rechecks the session, current token and case
   eligibility. USERCASETOKEN stays with Feedback.

## Isolated deployment and Roblox Mobile

The test Worker is `arcscriptcenter-banned-token-universal-qa`. Bind
`BAN_QA_DB` to an isolated QA database, `BAN_PUBLIC_QA_RATE` to its own
limiter, and generate `BANNED_TOKEN_SECRET` as a Worker secret. Apply the
existing verified history and Ban migrations, then the BANNEDTOKEN and
universal case session migrations, then
`banned_token_base32_ISOLATED_QA_ONLY.sql` to that QA database. This fixture contains
synthetic IDs only. It must never publish real case data to a test client.

Start the staging preview normally to use the existing public QA source.
Explicitly pass `"universal_case_qa"` to the preview entrypoint to make both
public status and private cases use the new isolated fixture. A positive
Mobile test needs an authorized account in the isolated QA allowlist, a
synthetic case linked to that account, and a private enrollment issued for
it. The original QA account and cases are outside this fixture.

Test in any compatible experience with no project-side Roblox scripts:
confirm Clear, Restricted Mode with authorized and unauthorized Violation,
and Ban in-game with SetUp only. Check the masked reference, close and
reopen the loader with Remember enabled, then disconnect and verify it
disappears. Submit an eligible Appeal from Violation and verify replay after
Approved is rejected. If a player was already fully banned before their
first link, SetUp keeps the existing appeal instructions. First enrollment
is available inside Arcsen in Clear or Restricted Mode, so support must
arrange initial access separately for fully banned users.
