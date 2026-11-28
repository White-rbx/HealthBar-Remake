# ArcScriptCenter — Native User's Case and Trash Preview Candidate (18 Nov 2026)

**Current status: source candidate built and local tests PASS (3/3). NOT deployed to Pages. Step 2/4 remains open.**

A ChatGPT conversation artifact has been generated:
`ArcScriptCenter_STAGING_UsersCase_Trash_Native_Preview_REVIEW_ONLY.zip`.

Source reference: original Stage16.49 Pages advanced-mode Function (`_worker.js`) from the owner's earlier conversation, NOT the exact current canonical Function source. The generated `_worker_candidate.js` SHA256 is **5898b0ee1ef5eb86fc93f2842d8cb7899fdf2b61c98d64cc4a62907aebe40e7c**.

## Candidate functionality
- Inserts native User's Case and Trash UI in the existing Feedback & Appeal (Beta Feature) panel and preserves the original dashboard HTML through HTMLRewriter.
- Uses the existing Admin page's **memory-only Admin Key**; never adds a second login or puts credentials in URL/storage.
- Uses existing authenticated five-status Admin list API to group cases by claimed UserId or Unknown / Unlinked and show known Ban List Usernames where available; **does not claim Roblox Display Name integration is live**.
- Allows a confirmed Admin-only Move of unlinked Feedback to the separate deployed STAGING Trash Gateway; restores before 30-day expiry, using current Endpoint `https://arcscriptcenter-trash-admin-staging.kogpasan14.workers.dev/api/v1/admin/feedback/unknown-trash`.
- Lock clears displayed User's Case and Trash data. A new unrelated/changed page layout makes integration skip rather than overwrite existing content.
- The candidate is explicitly bounded to 20 pages per status (50 items per page), with an error when too many records are present, rather than silently truncating.
- HTML/script and worker syntax validated with Node; 3/3 local synthetic integration smoke checks passed (native source injection, assets/response headers, graceful skip).

## IMPORTANT: BLOCKER for deploying Preview
Cloudflare canonical **STAGING Pages** deployment remains `3a36ea6d-d867-45a0-931d-87f6df64ed8c`, with `/index.html` asset hash `b388e6140f1ade679f99046116732ecb` and `/acs-logo.png` hash `4b25ba35fd0d822ee53b65413f589a48`. Both assets and the current Pages Functions MUST be retained.

The available old Stage16.49 `_worker.js` has not been reconciled with the exact current canonical Pages Function, and the Cloudflare connector cannot fetch the canonical HTML body. Also a fresh Pages Preview's Origin is not currently on the original Admin API and Trash Gateway exact CORS allowlists.

**DO NOT** upload the review-only ZIP as an entire Pages deployment. It intentionally lacks `index.html`/logo and would reproduce the previous STAGING outage. The prepared candidate must first be merged against a complete current Pages site and deployed only as a separate authorized Preview branch with correct CORS; then perform real Admin unlock, five-status case grouping, Move/Restore on synthetic data and rollback checks. No Production changes.

## State preserved
- The existing STAGING D1 Trash schema, hourly scheduled purge Worker and standalone Admin Gateway are deployed from prior work.
- Main STAGING API Worker and canonical Pages were not modified in this candidate step.
- Existing real 7 Feedback cases (3 missing claimed UserId) were not moved or deleted.
- PR #16 remains Draft.

The next milestone is **one** remaining UI Preview acceptance job, not restarting the Backend or another D1 backup exercise.
