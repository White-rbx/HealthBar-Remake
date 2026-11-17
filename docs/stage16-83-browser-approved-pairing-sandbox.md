# ArcScriptCenter — Stage 16.83: Browser-Approved Pairing (Offline Sandbox)

Date: 2026-11-17 (Asia/Bangkok)
Status: **DEVELOPMENT DRAFT / GitHub Actions only. No live service deployment.**
Base: Stage 16.82 OAuth state/session Sandbox.

## Feedback & Appeal rules clarification

The project Rules 1.1–1.6 and 2.1 do **not** specify a minimum account age for Feedback or Appeal. Read-only inspection of `arcscriptcenter-api-staging` `fcSubmit` also found no minimum-age or date-of-birth gate. Feedback submissions are subject to text limits and anti-spam quotas; Appeal currently also checks validity of a claimed Roblox UserId without establishing identity.

**Do not add an arbitrary account-age restriction** to the existing Feedback & Appeal flow. Roblox's developer ID-verification requirements for creating an OAuth application and account permissions to authorize OAuth apps are separate issues and do not create a Feedback age rule.

## Pairing design (non-privileged)

Untrusted Arcsen Luau client can request a random 80-bit display code and a 256-bit poll-only capability. The server stores SHA-256 hashes of both and a five-minute expiration. No Roblox `UserId`, OAuth token, cookie, moderator note, or violation history is sent to Luau.

A browser already holding a Stage16.81/82 server-verified Roblox OIDC session can **preview** that display code, view an explicit warning, and then **approve** using an additional one-minute browser-only confirmation token. An explicit manual confirmation is required. The Luau client can only poll for `pending` or a single-use `approved` flag. No browser login or Roblox ID is returned to Luau.

This is **not** proof that the requesting executor is running under the same Roblox account as the approving browser. Another person can initiate a code and persuade an account owner to approve it; therefore this protocol MUST NOT grant user-specific Violation History or management permissions. A future account-bound identity integration requires stronger trusted-client attestation or a trustworthy supported Roblox login arrangement.

## Files in Draft PR

- `sandbox/stage16-83-pairing-ceremony.mjs`: five-minute random pairing codes and browser-only one-minute confirmation
- `sandbox/stage16-83-pairing-d1.mjs`: isolated D1 adapter with single-statement conditional UPDATE/DELETE RETURNING for approval and poll consumption
- `sandbox/stage16-83-pairing-router.mjs`: fixed HTTPS-origin POST routes; browser approval requires matching Origin; rate limiter is mandatory
- `sandbox/stage16-83-pairing.test.mjs`: offline malicious-client, cross-account, wrong-browser, expiry, replay and one-time confirmation cases
- `migrations/2026-11-17_stage1683_pairing_sandbox_only_DRAFT.sql`: **not applied anywhere**, for a completely separate sandbox database
- `sandbox/test_stage16_83_sqlite.py`: real offline SQLite transaction-race checks
- `.github/workflows/stage16-83-pairing-offline.yml`: CI only, includes Stage16.80–82 Node regressions

## Security and release blockers

1. Implement a real **distributed** rate limiter, not the test callback, to limit start/poll/preview/approve and discourage phishing/DoS.
2. Implement bot/abuse protections, request logging that omits codes/tokens and expiry pruning.
3. Confirm actual Cloudflare D1 `UPDATE/DELETE ... RETURNING` behavior under runtime tests on a **separate** sandbox database.
4. Do not activate real Roblox login until an officially eligible Roblox OAuth application exists and its secrets are configured only on the server.
5. Do not expose subject IDs, account-bound Violation History, Appeal write permissions or admin operations to a Luau executor based on a pairing boolean.
6. For trusted account-bound authorization, first establish a server-verifiable relationship to the actual Roblox player, independent of Lua-provided identifiers.
7. Keep current Feedback & Appeal age-agnostic under the project rules; honor Roblox platform rules as applicable.
8. Conduct phishing/consent-abuse UX review (warning not to approve somebody else's code), mobile QA, and further server-side security review.

**Cloudflare Production and STAGING: unchanged. No Worker/D1 writes.**