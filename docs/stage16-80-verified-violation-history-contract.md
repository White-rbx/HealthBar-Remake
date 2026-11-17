# ArcScriptCenter — Stage 16.80: Verified Violation History (offline server contract)

Date: 2026-11-17 (Asia/Bangkok)
Status: **Prepared on dedicated GitHub development branch. Tested offline; NOT DEPLOYED.**
Base: Stage 16.79 UI (Arcsen UIs 7.3.43, user reports successful Roblox mobile UI test).

## Why this stage exists

Stage 16.79 introduced conditional Violation → Review / Approved / Denied / History, while preserving Feedback → Review / Approved / Denied. The Arcsen UI renderer remains intentionally PRIVATE and dormant until a trusted server can supply authenticated user-bound violations.

STAGING inspection (read-only) confirmed:
- Worker `arcscriptcenter-api-staging`, D1 `arcscriptcenter-staging`
- `asc_violation_notices` exists but has **zero rows**
- `asc_feedback_cases` has three active test cases (one Reviewing appeal, one Approved appeal, one Denied feedback)
- Existing `claimed_user_id` in `asc_violation_notices` is **not identity proof**
- No active Roblox OAuth/OIDC verification route was established by this stage

## Files

- `sandbox/stage16-80-verified-violation-history.mjs`: server-only query/HTTP handler factory
- `sandbox/stage16-80-verified-violation-history.test.mjs`: fail-closed isolation and state tests
- `migrations/2026-11-17_stage1680_verified_violation_history_DRAFT.sql`: additive schema draft; **do not execute on live D1**
- `sandbox/test_stage16_80_sqlite.py`: migration/FK/tenant-isolation offline test

## Contract (NOT an active endpoint)

A future Worker integration can mount `GET /api/v1/violation/history` **only after** establishing a real verified principal via Roblox OAuth2/OIDC server-side login/session. Do not trust the input claim `identityVerified` or `claimedUserId` from Luau, HTTP headers or query parameters. Case receipt credentials authenticate possession of *one case* but not Roblox account identity.

The handler calls a separately supplied `resolveVerifiedPrincipal(request)` (to be implemented and security reviewed), then derives only that trusted principal's `sub` (Roblox UserId). It uses parameterized queries against *server-linked* `asc_verified_violation_subjects`, not legacy `claimed_user_id`, and returns no admin-only notes.

If unauthenticated: 401, no data. If authentication provider/D1 is unavailable: 503, no data. If authenticated but no linked history: 200 with `hasHistory=false, notices=[]` → UI stays hidden.

Sample server-controlled response:

```json
{
  "ok": true,
  "identityVerified": true,
  "hasHistory": true,
  "notices": [{
    "id": "example-only",
    "reason": "Example rule",
    "moderatorMessage": "Public moderator message",
    "appealStatus": "reviewing",
    "layoutOrder": 1,
    "canAppealAgain": false,
    "createdAt": 1794800000,
    "history": []
  }]
}
```

## Status/UI behavior

| State | Color | LayoutOrder | Subcategory | Can submit Appeal |
| --- | --- | --- | --- | --- |
| `not_appealed` | Blue | 0 | Review | Yes, if server permits |
| `reviewing` | Orange | 1 | Review | No duplicate |
| `denied` | Red | 2 | Denied | Only with explicit server `may_reappeal=1` |
| `approved` | Green | 3 | Approved | Never again for same case |

History is ordered by server event time; only up to 20 public events per notice are returned. The overall response is capped at 50 notices.

IMPORTANT: `canAppealAgain` is UI metadata, not a write authorization. The **actual appeal submission Worker must atomically re-check server status** before accepting a submission, to stop tampered clients and duplicates. This is not implemented in the Stage 16.80 draft.

## Identity setup requirements before integration

Official Roblox OIDC uses `openid` and a server-verified ID token (`sub`, issuer, audience, expiration, nonce, ES256 signature/JWKS). Roblox currently requires eligible ID-verified creators to register/publish OAuth 2.0 apps. Do not bypass eligibility requirements. App credentials and long-lived tokens belong only in protected server secrets, never client Luau or a public repo.

References:
- https://create.roblox.com/docs/cloud/auth/oauth2-overview
- https://create.roblox.com/docs/cloud/auth/oauth2-reference
- https://developers.cloudflare.com/workers/runtime-apis/web-crypto/

## Offline results

- Node tests: **18 passed / 18 total**
- SQLite schema and account isolation / foreign-key checks: **PASS**
- No Cloudflare writes, D1 migrations or Worker deployments.
- No Production changes or merge.

## Still pending

1. Legitimate Roblox OAuth2/OIDC app configuration and a server-side verifier, with proper login, account binding, session expiry and revocation.
2. Secure staff-only creation of verified account/notice links; no migration from unverified `claimed_user_id` without evidence.
3. Atomic server-side Appeal state transition + audit log.
4. Runtime integration between the authenticated Worker response and Arcsen Violation UI (including multiple notices); retain 350px user-designed notice.
5. Negative tests for forged users, tampered Luau client, expired/revoked session, duplicate appeals, no-history, and signed public note HTML/RichText escaping.
6. Separate Sandbox/Staging E2E and actual Roblox mobile QA before any release decision.

**Production stays NO-GO.**
