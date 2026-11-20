# ArcScriptCenter — Production D1 logical restore and rollback readiness

**Date:** 2026-11-17 · **Status:** Logical restore **PASS**, downloadable SQL backup/import workflow **NOT YET VERIFIED**. **No production release authorized.**

## Safety boundary

This is a standalone, unbound, account-private logical data clone. The original Production D1 (`arcscriptcenter-db`) was only queried; all CREATE TABLE, INSERT and CREATE INDEX operations were performed against the **separate target** database `asc-prod-backup-restore-20261117`.

The target contains copied **real Production data**. Treat it as confidential. Do not connect it to any live Worker, expose it through public endpoints, commit its records to GitHub, or share its data in QA screenshots. Audit the target's retention and remove it only by a later explicitly authorized maintenance action once the necessary evidence has been retained.

## Actual Cloudflare D1 identities

| Resource | Name | UUID |
|---|---|---|
| Source, READ ONLY | `arcscriptcenter-db` | `f093d624-1266-4e35-9886-72dded7df58f` |
| Logical restore target, WRITABLE TEST ONLY | `asc-prod-backup-restore-20261117` | `7b5ba5b1-ce72-4796-bbc3-67c931483e71` |

The two identifiers were checked before each restore operation. A Worker settings audit covered **all 4 Worker scripts** in the account, and found **0 bindings to the new test D1**. No new binding was configured.

## Read-only source and cloned target checks

| Test | Result |
|---|---|
| Application tables | **22/22** |
| Explicit indexes | **23/23** |
| Application data rows | **2,626/2,626** |
| SQLite table definitions | Exact SQL text match |
| SQLite index definitions | Exact SQL text match |
| Per-table row counts | Exact match |
| Per-table row data | Exact canonical row-content match, 22/22 tables |
| Source quick_check | `ok` |
| Restore target quick_check | `ok` |
| Source foreign_key_check | No violating rows |
| Restore target foreign_key_check | No violating rows |
| Source bookmark during final content verification | Unchanged before vs. after final verification |
| Production source writes by this workflow | **None** |
| Production Worker/Pages deployments by this workflow | **None** |

The current target file size differs from the source because of page layout and index creation; it is **not** a byte-for-byte SQLite file copy. The data comparisons are logical, not a comparison of database file hashes.

Note: the **source bookmark had advanced compared with a previous export attempt** before the final comparison, likely due to unrelated source activity. At final verification, the bookmark was stable, all rows matched, and both database schemas matched. This is NOT a guarantee of a consistent point-in-time export across the earlier logical-copy interval.

## SQL export/download limitation

The standard Cloudflare D1 SQL export API with `{output_format:"polling",dump_options:{compatibility:"d1"}}` returned `complete` and a one-hour signed SQL download link. However, attempts to GET that signed link from the available Cloudflare connector runtime returned **HTTP 403**. Therefore:

- No durable downloadable full `.sql` archive was produced by this workflow.
- No official D1 `import` operation using that archive was tested.
- The separate D1 was populated using the **D1 REST query API** and then independently checked in full, not by importing the exported file.
- Cloudflare `PRAGMA integrity_check` was unavailable through this API (HTTP 400). `PRAGMA quick_check` and `PRAGMA foreign_key_check` both succeeded.
- **Do not write "official SQL backup/restore passed" in release notes.** The correct result is **isolated logical clone and read-back verification passed**.

An independent full-file SQL export + import test is still needed via an authorized Dashboard/Wrangler/other approved mechanism, with the SQL stored privately and a **fresh, separate** restore destination. Never include tokens, presigned URLs or SQL data in the repository or chat.

## Rollback anchors — verified read only

| System | Current production version/deployment at audit |
|---|---|
| Production Pages `arcscriptcenter-dashboard` | `b3bb02db-229c-46ec-a69b-3322359778f2` |
| Production API Worker `arcscriptcenter-api` | Version `298de84d-418c-489c-b133-c549c785f66e` at 100%; deployment `e1e42a95-61f2-43a5-b7cf-b53236c5b156` |
| STAGING Pages `arcscriptcenter-dashboard-staging` | `3a36ea6d-d867-45a0-931d-87f6df64ed8c` |
| STAGING API Worker `arcscriptcenter-api-staging` | Version `374b23ac-98ec-45f2-a586-03bb262db72b` at 100% |

**Important:** STAGING Pages uses a `production` environment label for its own `main` branch; it remains a separate project from the actual Production Pages project.

## Production deployment gate — not satisfied yet

1. Independently obtain a **durable SQL export file**, verify its integrity and confidentiality, then rehearse **actual import** into a fresh isolated D1. Never upload Production SQL to a public repository.
2. Inspect the Production Worker and Dashboard source diff, server-side Admin authentication, CORS, English UI and confirmed UserId-as-**unverified metadata** behavior. Confirm that Case ID + Receipt can access only that case and that unverified UserId does **not** unlock private Violation History or admin actions.
3. Produce a deployment-rollback plan preserving the Production D1 binding and Worker Secrets, with a known previous Worker version, previous Pages deployment, and a stop condition if the D1 schema/data differs unexpectedly. A production D1 rollback must be separately authorized and must not overwrite newer user data blindly.
4. Obtain explicit owner signoff before merging PR #16 or promoting any Worker/Pages code to the Production project.

## What this report does *not* imply

This proof does **not** authorize Production deployment, imply a SQL restore archive exists, or claim that Production is already running the latest STAGING Feedback changes. It shows the main dataset can be logically reconstructed in a separate D1 and verified **without mutating the source**. The project still requires an independently verified durable SQL backup and an approved release gate.

Related prior work: `docs/feedback-staging-native-userid-acceptance.md`, PR #16 (kept in Draft), and `docs/feedback-pages-preview-upload-handoff.md`.
