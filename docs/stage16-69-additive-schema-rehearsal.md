# ArcScriptCenter — Stage 16.69: Additive Feedback & Appeal D1 Migration Rehearsal

Date: 2026-11-15 (Asia/Bangkok)
Scope: **Read-only schema comparison of Production/Staging/Sandbox, schema-only replay on new isolated D1, GitHub test-branch migration draft. No Production deployment, data export or database mutation.**
Release gate: **Production NO-GO**.

## 1. Stage16.68 Access test update

User confirmed the protected `/__stage1667/integration` URL displayed **Cloudflare Access Login** from a clean Incognito session. This **passes the unauthenticated/no-session challenge visibility check**, not the denied-email / disallowed authenticated identity check. That separate check remains open.

## 2. Read-only D1 schema audit

| Environment | Tables | Declared Indexes | Worker source version |
|---|---:|---:|---|
| Production `arcscriptcenter-db` | 22 | 23 | `0.5.41.5-phase1` |
| Staging `arcscriptcenter-staging` | 17 | 20 | `0.5.67.1-cors-response-staging` |
| Sandbox `asc-stage1658-prodlike-20261115` | 28 | 31 | `0.5.73.0-feedback-real-integration-sandbox` |

All 45 explicit Production schema objects were also present in Sandbox with matching normalized SQL definitions. Sandbox has **18 additional CREATE objects**: six tables, eight indexes and four triggers for Feedback & Appeal, with no extra Production-only objects. The additional objects include `asc_feedback_cases`, `asc_feedback_history`, `asc_feedback_followup_history`, `asc_feedback_followup_details_history`, `asc_feedback_quota`, and `asc_feedback_quota_v2`.

Staging is **not** equivalent to either environment: it lacks `asc_feedback_quota_v2` and differs from the newest Sandbox in several other table definitions. Do not simply apply the Production-specific migration to Staging or promote either Worker without a separate compatibility review.

Production Worker source did **not** contain the new Feedback Submit API or Siteverify logic. This is an additional compatibility blocker beyond schema drift. Simply adding the tables does **not** complete a production release.

## 3. Additive migration proposal — DRAFT ONLY

GitHub SQL draft:
`migrations/2026-11-15_stage1669_feedback_appeal_additive.sql`

The draft is extracted from currently deployed Sandbox **schema only**, not user data. It contains 18 CREATE statements (6 table, 8 index, 4 trigger), ordered so the tables exist before indexes and triggers. No data-export or record-mutation statements are included.

It is **not authorized to run on Production**, and should be gated by independently verified backup/restore capability, compatibility tests with existing data, migrations review, explicit release authorization and rollback planning.

## 4. Isolated migration rehearsal — PASS

Created D1 `asc-stage1669-schema-rehearsal-20261115`, independent of all three Worker D1 bindings, containing **no Production records**.

1. Recreated 45 exact Production schema objects using CREATE-only DDL; did not copy table contents.
2. Applied all 18 additional Feedback & Appeal schema objects from Sandbox.
3. Verified the resulting **63** explicit schema definitions match current Sandbox definitions by type, name and normalized SQL.
4. Inserted a purely fabricated Feedback fixture and performed an edit followed by soft-removal. Verified case `removed=1` and `revision=2`.
5. Verified Feedback history triggers yielded the ordered events **submitted → edited → removed**.
6. Verified `PRAGMA quick_check` returned `ok` and `PRAGMA foreign_key_check` returned no violations.

**Rehearsal result: PASS.** Note: attempting `PRAGMA integrity_check` through the D1 HTTP query API resulted in `SQLITE_AUTH`. This is an API restriction seen in this test; `quick_check` was used instead. Do not claim a full `integrity_check` pass.

After verification, confirmed the disposable DB had exactly the one expected soft-removed synthetic fixture and was not bound to any of the three Workers. Then **successfully deleted** the disposable D1 database. Production, Staging and the established Sandbox D1 were untouched by the rehearsal.

## 5. Current release gate

- [x] Stage16.64 HTTP contracts — 19/19 (user screenshot/confirmation).
- [x] Stage16.66 genuine Turnstile token contract — 4/4 (user screenshot).
- [x] Stage16.67 real Turnstile Feedback and Appeal lifecycle — 11/11 (user screenshot).
- [x] Stage16.67 isolated Sandbox synthetic record cleanup.
- [x] Stage16.68 clean Incognito browser received Cloudflare Access Login (user-confirmed).
- [x] Stage16.69 schema-only additive migration rehearsal with synthetic trigger checks.
- [ ] Authenticated user not allowed by Access email policy — deny browser check.
- [ ] Production-specific Worker code/API compatibility and staging migration review.
- [ ] Independently exported/restorable Production D1 backup, verified in a separate destination.
- [ ] Arcsen/Roblox client and browser end-to-end approval tests.
- [ ] Full change plan, risk review, operational rollback and explicit Production signoff.

**Production remains NO-GO.** No Production action was performed or requested.

References:
- https://developers.cloudflare.com/d1/reference/time-travel/
- https://developers.cloudflare.com/cloudflare-one/access-controls/policies/policy-management/
