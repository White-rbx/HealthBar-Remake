# Stage 16.64 — Turnstile Negative Test Regression Fix (Sandbox only)

Date: 2026-11-15 Asia/Bangkok

## Authorized tester browser results
- Synthetic Feedback & Appeal test: 10/10 PASS (feedback and appeal submit/status/edit/remove/receipt denial).
- Safe Tests: 8/9 PASS. The invalid-token check expected HTTP 403 but got HTTP 201.

## Investigated behavior
The stage16.64 browser negative test POSTed a test feedback submission with `turnstileToken: 'NOT.A.VALID.TOKEN'`.
In the dummy test-key configuration this reached a successful submit and created an unintended sandbox Feedback record. The test's name claimed to be read-only, yet the implementation used the write endpoint.

## Deployed remediation
Worker `arcscriptcenter-merge-sandbox-1658` updated to `0.5.71.2-protected-http-tests-sandbox` (version ID `b4e5a84a-87f3-4da6-bae5-3481636726b8`), deployed to 100% sandbox traffic.

- In `sandbox-dummy` mode only, explicitly reject any test token other than Cloudflare's documented `XXXX.DUMMY.TOKEN.XXXX` before Siteverify. Real-key Production path remains unchanged.
- Negative test now calls `POST /__stage1664/turnstile-rejection`, a sandbox-only Access-protected verifier contract endpoint that invokes `ascVerifyFeedbackChallenge` without calling submit, quota or D1 mutations. It cannot create Feedback even if the validator unexpectedly accepts a token.
- Updated browser health version assertion to `0.5.71.2-protected-http-tests-sandbox`.
- All seven Worker bindings inherited and verified by name/type. No secret values inspected. No edits to GitHub `main` or Production.
- Previous version `a67cfdd7-2332-4f76-b10e-6a59aa2e5d5e` remains available for rollback.

## Sandbox data observation — read-only SQL

After the tester's earlier run, one active `feedback` row with exact topic `Stage1664 Negative Test` and `removed=0` remained in sandbox D1. Separately, one Feedback and one Appeal synthetic test row were present with `removed=1`. **No cleanup, UPDATE or DELETE was performed** in this stage. Any later cleanup should target verified synthetic records in sandbox only, with specific predicates; never bulk-delete real feedback or touch Production.

## Retest
Open the existing Access-protected `/__stage1664/contract` test page and perform `Run Safe Tests`. Expected 9/9 PASS with Invalid Turnstile HTTP 403. This browser outcome has not yet been confirmed by the assistant; do not mark verified without the authorized tester result. Synthetic 10/10 was confirmed on the previous deployed version; retest if a full regression pass is desired.

## Release status
Production remains NO-GO. Sandbox dummy keys are only testing fixtures and do not provide real spam protection. Full production release remains blocked on real-key Turnstile, origin/action checks, unauthorized Access tests, Arcsen/browser integration and independently restorable Production D1 backup.
