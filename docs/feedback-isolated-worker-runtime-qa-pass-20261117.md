# ArcScriptCenter — Live D1 Anti-spam Runtime QA PASSED (2026-11-17)

**PASS — actual Cloudflare Worker execution with isolated Cloudflare D1 and synthetic identities, not just SQLite mocks.**

## Evidence

- GitHub Actions run: https://github.com/White-rbx/HealthBar-Remake/actions/runs/44129277358 — **success**.
- The runner sent one actual HTTP POST to disposable, isolated Worker `asc-feedback-synthetic-runtime-20261117`, which had ONLY:
  - D1 binding `DB` → `asc-feedback-release-qa-20261117` (`fb828e2b-b10b-41ac-95bd-3873ff3cccd5`).
  - Disposable, generated secret binding `QA_RATE_KEY`.
- No real user case records, Production secrets, Production D1, STAGING D1, or Admin Key were connected.
- Runner received **HTTP 200** and verified:
  - Synthetic network A: **6 accepted**.
  - Same network, 7th submission: **HTTP 429**.
  - Independent network B: **accepted**.
  - Explicitly untrusted ingress callback: **HTTP 503**, fail-closed.
  - Cloudflare edge request metadata was present.
- The test invoked the **actual `createReleaseFeedbackRateGuard` module** from `sandbox/feedback-release-rate-guard.mjs`, not an independently rewritten algorithm. The synthetic QA-only harness selected two fixed fixture network identities from code, **not** a verified real production client-IP path. The production ingress adapter still requires separate verification.

## Temporary resource cleanup

- **Deleted** disposable QA Worker `asc-feedback-synthetic-runtime-20261117` after the successful GitHub run. Its only bindings were `DB` and `QA_RATE_KEY`.
- The isolated D1 received 7 synthetic rate-window rows (six scope buckets plus one run-once lock). All **7** were deleted after verification. D1 rate-window rows remaining: **0**.
- Isolated D1 `quick_check = ok`, **0** foreign-key violations.
- Prior HTTP 404 on Cloudflare **Preview** URLs is separately documented in `docs/feedback-preview-runtime-qa-blocked-20261117.md`; the Preview was deleted and the Sandbox Worker's `previews_enabled` setting returned to its original `false` value.
- Existing Production and STAGING Workers and Pages were **not deployed** in this test.

## Scope of proof and remaining release gates

**Confirmed now:** the new HMAC D1 limiter runs inside a real Cloudflare Worker, performs its atomic D1 operations correctly in the test, separates independent identities and fails closed for untrusted input.

**Not confirmed by this test:** the full 106,382-byte assembled Feedback/Appeal Production Candidate receiving native Arcsen submissions; end-to-end Admin case access/Receipt and the true Cloudflare edge provenance adapter on the target Production hostname. The accepted **undeployed** candidate Version remains review-only.

**Release restrictions remain:** Production D1 still lacks Feedback tables; reconcile and separately authorize additive migration. Verify Production hostname/secret/CORS/edge trust; review actual integrated Worker runtime; confirm rollback and owner's explicit Production approval. The SQL backup file export/import blocker was **not retried**.

This is a successful, material advancement without touching Production: **live runtime limiter gate PASSED; full integrated release gate still pending.**
