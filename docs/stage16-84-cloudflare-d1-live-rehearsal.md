# ArcScriptCenter — Stage 16.84: Isolated Cloudflare D1 Live Rehearsal

Date: 2026-11-17 (Asia/Bangkok)
Status: **Cloudflare D1 REST schema and SQL behavior verified on a new isolated Sandbox D1. No Worker deployed.**
Parent: `stage16-83-browser-approved-pairing-sandbox`
Environment: **Sandbox only — not Production, not existing STAGING.**

## Exact database and scope

Created dedicated Cloudflare D1 `asc-stage1684-identity-sandbox-20261117` in Asia-Pacific using the connected Cloudflare account. No existing database bindings were modified.

The D1 UUID is intentionally excluded from the public GitHub report; the owner can find the isolated resource by name in Cloudflare Dashboard.

Applied only the two existing draft migration files from Stages 16.82 and 16.83 to this **new** database:

- `migrations/2026-11-17_stage1682_oidc_sandbox_only_DRAFT.sql`
- `migrations/2026-11-17_stage1683_pairing_sandbox_only_DRAFT.sql`

Cloudflare D1 REST accepted all **8 migration statements** (3 tables, 4 indexes, plus PRAGMA foreign_keys configuration). The three sandbox tables are `asc_oidc_pending`, `asc_oidc_sessions`, and `asc_pairing_sandbox`.

**No real Roblox UserIds, OAuth tokens, user Feedback, violations, or passwords were used or inserted.** All test principals and strings were synthetic placeholders and temporary.

## Observed Cloudflare D1 REST results

| Test | Observed | Result |
|---|---|---|
| Schema creation (8 statements) | All 8 success | PASS |
| OAuth pending state `DELETE ... RETURNING` | First delete returned 1 row; second returned 0 | PASS |
| Pairing preview (verified subject placeholder) | First preview 1 row | PASS |
| Different subject preview attempt | 0 rows | PASS |
| Different subject approval | 0 rows | PASS |
| Wrong confirmation hash | 0 rows | PASS |
| Two concurrent same-state approvals | Exactly one returned a row: `[1,0]` | PASS |
| Approved pairing state visible to poll | `approved` | PASS |
| Two concurrent Approved poll/consume attempts | Exactly one returned a row: `[0,1]` | PASS |
| Pairing row after consumption | 0 | PASS |
| Correct session hash | Returned synthetic account reference | PASS |
| Incorrect or expired session hash | 0 rows | PASS |
| Duplicate session insertion to replace owner | SQLite UNIQUE constraint rejection | PASS |
| Owner after attempted replacement | Unchanged | PASS |
| Session revocation using DELETE | No subsequent session lookup | PASS |
| Expired OAuth pending state prune | 1 expired row removed | PASS |
| Session expiry CHECK constraint | Invalid TTL rejected | PASS |

**Final cleanup verified:** `asc_oidc_pending=0`, `asc_oidc_sessions=0`, `asc_pairing_sandbox=0`. Four expected non-unique indexes were visible in the schema. Sandbox database was kept, empty and isolated, for follow-up controlled testing.

## What was NOT verified

- **`PRAGMA integrity_check` returned `SQLITE_AUTH` through the Cloudflare D1 REST query API.** Do not claim a successful integrity_check; tables, indexes, constraints, data counts and atomic SQL return behavior were verified instead.
- Testing used **Cloudflare REST D1**, not a Worker runtime D1 binding. Worker runtime integration remains to be tested.
- There is still **no real registered Roblox OAuth application**, no live Roblox token exchange, no live login and no account-bound Luau identity.
- There is **no server-to-server trust proof from an untrusted Luau executor**. The Stage16.83 pairing completion boolean must never be treated as authorization to read private Violation History, access appeal/moderator actions or impersonate another Roblox account.
- A distributed rate limiter and explicit anti-phishing consent UI remain release blockers.
- This Stage did not perform Production backup/restore, migrations, or Production deployment.

## GitHub guard

Added `sandbox/stage16-84-d1-isolation-guard.test.mjs` and `.github/workflows/stage16-84-d1-rehearsal.yml`. The guard locks the migration contract to precisely three isolated tables, four indexes, and forbids changing existing Production/STAGING schemas, destructive SQL, or sensitive token columns. The workflow runs Stage16.80–16.83 offline regressions.

GitHub Actions is offline-only; it does **not** use Cloudflare credentials or connect to live D1. This avoids putting powerful Cloudflare tokens into a public development workflow.

## Next suggested Stage 16.85

Before opening any public Worker endpoints, implement and offline-test **distributed rate-limiting and anti-phishing checks** for Pairing (including `start`, `preview`, `approve`, `poll`, `cancel`). Separate an independently reviewable non-privileged Pairing Sandbox Worker from existing API workers. Keep all user-specific Violation and Appeal permissions disabled until actual server-verifiable Roblox identity exists.

## Explicit safety boundary

**Cloudflare Production `arcscriptcenter-db`: unchanged. Existing `arcscriptcenter-staging`: unchanged. No Worker deployed and no OAuth secrets created. Feedback & Appeal age restrictions were not added.**
