# Stage 16.64 — Protected HTTP Contract Tests: 503 Diagnosis & Sandbox Fix

Date: 2026-11-15 (Asia/Bangkok)
Scope: `arcscriptcenter-merge-sandbox-1658` ONLY. Production and `main` are not release targets.

## Browser evidence reported by authorized tester

- Safe read-only/rejection checks: **8/9**. Invalid Turnstile expected HTTP 403 but returned HTTP 503.
- Synthetic feedback and appeal cases: **0/2**. Both submit requests returned HTTP 503.
- Health, D1, 404/405, malformed input, missing token, invalid receipt/manage, and missing-admin-key checks passed.
- Cloudflare Access login and authenticated health were confirmed in earlier stage.

## Root cause (verified against deployed Sandbox Worker source and bindings)

Deployed Worker version was `0.5.71.0-protected-http-tests`, but the verifier gated dummy mode on `VERSION.includes('-sandbox') && env.ASC_TURNSTILE_MODE === 'sandbox-dummy'`. Because the version string omitted `-sandbox`, the mode guard was false despite the configured `ASC_TURNSTILE_MODE=sandbox-dummy`. No `ASC_TURNSTILE_HOSTNAME` binding was configured (as expected for dummy mode), so the verifier returned HTTP 503 before calling Turnstile Siteverify.

## Remediation deployed to Sandbox

- Uploaded Worker version `0.5.71.1-protected-http-tests-sandbox` with just the two literal version references updated: the Worker `VERSION` constant and browser health assertion.
- Inherited **all seven existing bindings** from the previous Worker version through Cloudflare's version API. Names/types verified after upload; secret values were not read or printed.
- Deployed the new version to **100% of Sandbox traffic**; metadata confirmed it is current.
- Prior deployed version `b7ecf766-c25b-46e5-ba38-289f07bc1163` is retained for rollback. New version: `a67cfdd7-2332-4f76-b10e-6a59aa2e5d5e`.
- No Production deployment, D1 data mutation, or GitHub `main` change.

## Next protected browser retest

Visit the same Access-protected Sandbox endpoint `/__stage1664/contract`.

1. Press **Run Safe Tests**: expected **9/9**, especially Invalid Turnstile HTTP 403.
2. Press **Run 2 Synthetic Cases** once: expected **2/2** after successful submit/status/edit/remove flows.
3. Record only pass/fail counts and HTTP statuses using the Safe Summary. Never paste Access cookies, receipt strings, personal data, or secrets.
4. Synthetic tests may write sandbox D1 records and soft-delete them. Plan explicit cleanup afterward; do not assume deleted rows have disappeared.

These post-deployment HTTP results are **not yet verified** by the assistant because Cloudflare Access restricts the endpoint to authorized browsers.

## Release gate

Production remains **NO-GO**. Official Turnstile dummy keys are for deterministic sandbox tests only and do not provide real anti-abuse protection. Real Turnstile keys, origin/action checks, unauthorized-session access denial, browser/Arcsen integration tests, and verified production D1 restore are still required prior to any release.
