# ArcScriptCenter — Stage 16.65: Sandbox Acceptance, Cleanup & Release Gate Review

Date: 2026-11-15 (Asia/Bangkok)
Scope: **Read-only inspection of Production & Staging, authorized cleanup of verified test records in isolated Sandbox D1, and documentation on test branch only.**
GitHub branch: `stage16-63-protected-http-test`
Production deployment: **NO-GO**

## 1. Stage 16.64 HTTP test results (user reported)

The authorized tester explicitly confirmed that all tests passed after the Sandbox fix.

| Suite | User-confirmed result | What it covers |
|---|---:|---|
| Safe Read-only & Rejection Checks | **9/9 PASS** | Health/D1; unknown endpoint 404; wrong method 405; malformed submission 400; missing Turnstile 400; invalid Turnstile 403; invalid receipt 404; invalid manage 400; missing admin key 401 |
| Synthetic Feedback & Appeal | **10/10 PASS** | Feedback: submit 201, status 200, edit 200, soft remove 200, receipt denied 404; Appeal: equivalent five checks |
| **Total** | **19/19 PASS** | Authorized tester report, not independently replayed by ChatGPT |

The tests used `arcscriptcenter-merge-sandbox-1658` running `0.5.71.2-protected-http-tests-sandbox` (Worker version `b4e5a84a-87f3-4da6-bae5-3481636726b8`) with 100% traffic.

The negative-test verifier is sandbox-only, runs behind Cloudflare Access and does **not** submit to the Feedback database.

## 2. Sandbox D1 cleanup — COMPLETE

Target DB verified by both Worker `DB` binding and D1 metadata:
`asc-stage1658-prodlike-20261115` (`production` storage subsystem; **not** the real Production database).

A current Time Travel bookmark was available **before cleanup**.

Strict predicates limited matching to exact synthetic `kind`, `topic`, `description`, `removed` flag and a narrow `created_unix` time window. Candidate count and ID uniqueness were checked before the mutation.

Preflight records:
- One active Feedback row with topic `Stage1664 Negative Test`
- Two soft-deleted Feedback rows with topic `Stage1664 Synthetic Feedback Edit`
- Two soft-deleted Appeal rows with topic `Stage1664 Synthetic Appeal Edit`
- Thirteen linked rows in `asc_feedback_history`
- Zero linked follow-up or follow-up-details history rows

Executed D1 cleanup statements in the **Sandbox DB only**:
- Deleted **13** history rows linked to these five synthetic cases.
- Deleted **5** exact synthetic cases.
- Verified **0** remaining `Stage1664 %` case rows and **0** orphaned feedback history rows.

**No other tables were modified** by this cleanup operation. Anonymous quota tracking tables were not reset. Production and ordinary Staging D1 were not touched.

## 3. Configuration & security review — OBSERVED

| Scope | Observation |
|---|---|
| Sandbox Worker | Deployed target version 100%, seven expected bindings remain present |
| Sandbox Turnstile | Mode is `sandbox-dummy`, a **test-only** configuration; this cannot provide real anti-abuse protection |
| Cloudflare Access | A self-hosted Access application protects the Sandbox Worker. One allow policy targeting an email selector is present. Policy decision is `allow`; Access application session duration is **1 hour**. Authorized browser entry previously verified by tester |
| Worker preview URLs | Disabled for Production, Staging and Sandbox Worker subdomains |
| Workers.dev URLs | Enabled for all three; domain exposure is not equivalent to anonymous authorization |
| Isolation | Production, Staging and Sandbox Workers bind to **different D1 database IDs** |
| Production Worker | Existing `arcscriptcenter-api` remains deployed; its inspected bindings do **not** include the Sandbox Turnstile test mode/secret. No deployment changes in this stage |
| Production security tests | Real-key Turnstile response, expected hostname/action, denied identity and unauthenticated Incognito access **not proven** by this report |

Access policy inspection confirms configuration only; it does not establish that an unauthenticated or excluded account is actually denied without a real browser smoke test.

No secret **values** were read or printed.

## 4. Backup readiness — PARTIAL, NOT A RESTORE CERTIFICATION

D1 metadata and Time Travel bookmark endpoints were queried **read-only**:

| Database | Storage subsystem | Current Time Travel bookmark accessible |
|---|---|---|
| Production `arcscriptcenter-db` | `production` | YES |
| Staging `arcscriptcenter-staging` | `production` | YES |
| Sandbox `asc-stage1658-prodlike-20261115` | `production` | YES |

This confirms D1 Time Travel bookmark availability, **not** that Production data has been independently exported, restored, integrity-checked or validated as a separate recovery copy.

No restore, copy, export of Production content, or Production D1 data mutation was performed.

For a release-grade recovery test, produce a controlled Production backup/export through authorized procedure, verify access controls, restore into a **separate isolated test environment** (never in-place against the live database), validate schema, row counts and application queries, record restore evidence, and secure/delete temporary copies appropriately.

Cloudflare reference: https://developers.cloudflare.com/d1/reference/time-travel/

## 5. Release gates — Production NO-GO

- [x] Sandbox API contract tests — tester confirmed **19/19**
- [x] Sandbox synthetic case/history cleanup
- [x] Worker settings, Access allow-policy, D1-binding separation reviewed
- [x] Time Travel bookmark availability for all three D1 databases
- [ ] Confirm Access rejects unauthenticated Incognito sessions and unauthorized identities (no credentials should be shared)
- [ ] Validate real Turnstile sitekey/secret with **correct hostname and action** in an isolated pre-release environment
- [ ] Verify fail-closed behavior and abuse controls with real Turnstile (dummy keys are insufficient)
- [ ] Browser/Arcsen integration acceptance and full error-path testing
- [ ] **Independent, restorable Production D1 backup test**, with recovery evidence
- [ ] Explicit Production release approval and rollback procedure

## 6. Next suggested milestone

**Stage 16.66 — Real-key Turnstile in isolated pre-release environment, Access denial smoke tests, and independent database recovery drill.** Do not promote the Sandbox Worker or dummy keys to Production.

Release status: **Production NO-GO** until every mandatory gate is independently validated.
