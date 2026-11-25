# ESLogin / ArcScriptCenter — isolated QA D1 capacity recovered (2026-11-25)

**STAGING ONLY. No real accounts, sessions, Passkeys, Production changes or QA traffic rollout.**

## Conditional owner approval and deletion

The owner authorized retiring `asc-feedback-release-qa-20261117` **only if no application data remained**. Before deletion the following safeguards were completed:

- Exactly **7 accessible application tables**, all with **0 rows**, were rechecked immediately before deletion. The deletion operation refused to run if any count was nonzero or unverified.
- `PRAGMA foreign_key_check` found zero violations.
- All **13 current Worker script configurations** and all **3 Pages project deployment configurations** were inspected for direct D1 bindings; **none pointed to the target ID**.
- The Worker Preview inventory contained no Preview known to reference the retired D1. Historical QA documentation `docs/feedback-isolated-worker-runtime-qa-pass-20261117.md` confirms its disposable rate-limit Worker was deleted and its 7 test rows cleared.
- Cloudflare's reserved `_cf_KV` table was not queried (D1 returns `SQLITE_AUTH`), and it does **not** represent a user application table; Cloudflare documents it as internal storage metadata: https://developers.cloudflare.com/d1/best-practices/import-export-data/
- A **schema-only recovery artifact** containing all **21 user-defined SQL objects**, without any data rows or secrets, was archived in `docs/asc-feedback-release-qa-20261117-schema-archive-20261125.sql`, commit `dfd0a5cf9dbeb64a46c27433100ac997d6049081`. A D1 export task completed, but its signed R2 artifact could not be downloaded from the authorized connector environment (HTTP 403). Do not claim a verified full backup file exists.
- The former D1 ID was `fb828e2b-b10b-41ac-95bd-3873ff3cccd5`. Cloudflare DELETE succeeded and subsequent GET D1 inventory confirmed it is no longer listed.

## Replacement D1 (synthetic only)

| Field | Result |
| --- | --- |
| Name | `asc-eslogin-passkey-isolated-qa-20261125` |
| ID | `04715765-050f-4e26-b4f6-6101bba9dc97` |
| Location hint | `APAC` |
| D1 count after replacement | **10/10** |
| Source migrations | `asc_unified_account_ISOLATED_QA_ONLY.sql`, `asc_passkey_ISOLATED_QA_ONLY.sql`, `asc_passkey_backup_ISOLATED_QA_ONLY.sql`, `asc_passkey_recovery_ISOLATED_QA_ONLY.sql` |
| Applied SQL statements | **18/18 successful** |
| Account & Passkey application tables | **11** |
| App record counts | **0 in all 11 tables** |
| Foreign key violations | **0** |
| Assigned Worker binding | **NONE** (not yet configured) |

The 11 new tables are `asc_accounts`, `asc_account_sessions`, `asc_account_recovery`, `asc_account_pairings`, `asc_account_cases`, `asc_account_verified_links`, `asc_account_passkeys`, `asc_account_passkey_flows`, `asc_account_passkey_backup_flows`, `asc_account_passkey_recovery_codes`, and `asc_account_passkey_recovery_flows`. No synthetic or real account was created and no credentials were stored.

The GitHub `verifyPrivatePreviewPlan` gate now requires exactly `PIN.previewDb` matching this new ID, and rejects an arbitrary valid UUID or the pre-existing Account QA D1 ID. This guard does not itself authorize activating login.

## Isolation preserved

- Existing deployed Account QA Worker **Version 10 remains at 100%**.
- Uploaded Passkey **Version 11 remains undeployed at 0%**.
- `previews_enabled=false` on the existing Account QA Worker.
- The independently routed `arcscriptcenter-eslogin-edge-qa` Worker remains **Access DENY Everyone**, with **zero resource bindings** and static Provisioning responses; prior live unauthenticated GET and POST gave Cloudflare Access 302 challenges.
- Original `eslogin` Preview remains non-routable and Access DENY Everyone.
- GitHub PR #16 stays **Draft**.

## Next no-go gates

Before connecting the new synthetic D1 to an authenticated Worker, review (1) isolated Worker and fixed exact HTTPS WebAuthn Origin/RP ID; (2) Access policy restricted to synthetic testers and a fresh anonymous-edge denial test; (3) separate QA-only Turnstile keys with matching site hostname and `asc_register` / `asc_recover` action checks; (4) isolated rate limiting and synthetic-only secrets; (5) staging Pairing + Session + rejoin/logout + Android acceptance. Never enable Version URLs on the original QA Worker as a workaround, reuse the old Account QA D1, or merge PR #16 without explicit review.

**Current status: isolated D1 capacity and schema PASSED; live authenticated ESLogin integration NOT YET COMPLETE.**
