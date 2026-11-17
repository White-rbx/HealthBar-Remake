# ArcScriptCenter — Stage 16.85: Pairing Security / Abuse Protection

Date: 2026-11-17 (Asia/Bangkok)
Base: Stage 16.84 isolated D1 rehearsal.
Status: **Offline Security QA PASS + Cloudflare D1 REST sandbox SQL rehearsal PASS. No Worker deployed.**
Target: `asc-stage1684-identity-sandbox-20261117` ONLY.
Production `arcscriptcenter-db`: **unchanged**.
Existing `arcscriptcenter-staging`: **unchanged**.

## Changes in this branch

- `sandbox/stage16-85-d1-rate-limiter.mjs`: SQLite/D1 atomic fixed-window quotas for all Stage16.83 pairing actions.
- `migrations/2026-11-17_stage1685_pairing_rate_sandbox_only_DRAFT.sql`: additive isolated rate window table and expiry index.
- `sandbox/stage16-85-rate-consent.test.mjs`: fake shared-D1 multi-worker quota, HMAC privacy, fail-closed and explicit consent tests.
- `sandbox/test_stage16_85_sqlite.py`: real SQLite simultaneous upsert checks and expiry.
- `sandbox/stage16-83-pairing-router.mjs` + `sandbox/stage16-83-pairing.test.mjs`: require matching manually re-entered code and `acknowledgeOwnDevice:true` before approval; backward security regression tests updated.
- `.github/workflows/stage16-85-pairing-security-offline.yml`: run Stage16.80–85 offline regression checks.
- This report and a separate mobile/browser consent UX review checklist.

### Rate limiting contract

One shared sandbox D1 table `asc_pairing_rate_windows(scope_hash,window_start,hits,expires_unix)` with an atomic `INSERT ... ON CONFLICT DO UPDATE ... WHERE hits < ? RETURNING hits`, per minute.

| Action | Per trusted network / minute | Global / minute |
|:--|--:|--:|
| start | 4 | 150 |
| poll | 45 | 3000 |
| cancel | 8 | 400 |
| preview | 8 | 350 |
| approve | 6 | 300 |

These are **sandbox test thresholds**, not production policy. Review real usage, NAT/shared-IP impact, and availability before activation.

Server-only HMAC-SHA256 protects the scope of the trusted network identifier: only an opaque 43-character hash is stored. The raw IP and secret MUST NOT be stored in D1 or logs. `getTrustedNetworkId(request)` is intentionally injected; an actual Worker entry point must obtain network identity from authoritative Cloudflare edge metadata, **never** a user-supplied header such as `X-Forwarded-For`, a username, Roblox UserId or Luau payload. Missing trust metadata, secret, unknown action, invalid SQL response or DB outage **fail closed**.

A per-network limit is consumed first, then a separate global limit. This can use one of the per-network allowances even if global is exhausted; it is deliberately conservative and not a true multi-bucket all-or-nothing transaction. Periodically prune expired rows from a trusted server cron.

### Browser approval contract

Stage16.83 `POST /pair/browser/approve` now requires the following JSON fields:

```json
{
  "code": "ABCD-EFGH-IJKL-MNOP",
  "confirmationToken": "<server-issued-browser-only-challenge>",
  "confirmedCode": "ABCD-EFGH-IJKL-MNOP",
  "acknowledgeOwnDevice": true
}
```

The example code above is illustrative, not a real generated code and may not conform to the exact base32 alphabet. The browser must require the user to **manually type** `confirmedCode`; never auto-populate it from a received code, other webpage, query parameter, chat or Luau payload. The checkbox must start unchecked. The browser app still needs explicit UX implementation and full review; JSON fields alone cannot prevent social engineering or a compromised browser.

Same-origin Origin checks, Stage16.81/82 verified browser sessions, 60-second confirmation challenges, 5-minute pairing expiration, and single-use D1 pairing transitions remain required.

### Confirmed GitHub Actions result

Stage16.85 GitHub Actions run `44071370433` PASSED:
https://github.com/White-rbx/HealthBar-Remake/actions/runs/44071370433

New checks covered multiple simulated Worker instances using a shared database, HMAC-scoped privacy, global quotas, missing network identity, D1 outage, unknown actions, consent checks and SQLite concurrent UPDATE/UPSERT behavior. Stage16.80–84 regressions also passed.

### Confirmed Cloudflare REST D1 sandbox rehearsal

After checking the connected Cloudflare account had exactly one database named `asc-stage1684-identity-sandbox-20261117`, applied ONLY the two additive Stage16.85 statements (new rate-limit table plus index) to it.

Using **synthetic 43-character scope values**, one fixed SQL window and no user data:
- 12 concurrent attempts for a per-network limit of 4 returned winning counters **[1,2,3,4]**; no HTTP errors.
- 6 concurrent attempts for global limit 2 returned winning counters **[1,2]**; no HTTP errors.
- A different synthetic network was allowed independently and returned counter **1**.
- Checked D1 rows then deleted all synthetic counter rows; verified `asc_pairing_rate_windows=0`.
- Re-checked original isolated tables: `asc_oidc_pending=0`, `asc_oidc_sessions=0`, `asc_pairing_sandbox=0`.
- Read-only `sqlite_master` checks confirmed the **new Stage16.85 table is absent** from both `arcscriptcenter-staging` and `arcscriptcenter-db`.

This is real Cloudflare **D1 REST API SQL behavior**, **NOT** a deployed Worker binding/runtime test. Do not infer live rate limiting from these checks.

### Release blockers

1. No real Roblox OAuth 2.0 application, no eligible app registration, no live login or token exchange.
2. No trusted Worker edge-source implementation of `getTrustedNetworkId`; rate-limit secret MUST be a protected Worker binding. No Worker routes are mounted or deployed.
3. Rate limits require dedicated Worker/runtime integration QA, metrics, abuse/DoS tests and privacy/log redaction review. Consider provider WAF/Turnstile when relevant.
4. Browser consent page and anti-phishing UX are **not deployed**. Manual code entry reduces accidental linking but cannot prove ownership of an untrusted Luau device and cannot eliminate phishing.
5. The browser-approved pairing boolean MUST NEVER authorize private Violation History, Roblox subject impersonation, Appeal mutation or moderator access.
6. Reviewer must confirm session verification, rate-limit policies, replay protection, expiry cleanup, Cloudflare D1 compatibility, trust boundaries and mobile behavior before considering release.
7. Feedback & Appeal does **not** have any newly introduced account-age gate. Current project Rules are unchanged.

**Production NO-GO. Stage16.85 is a security sandbox milestone, not a shipped authentication system.**
