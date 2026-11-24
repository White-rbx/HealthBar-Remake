# ArcScriptCenter Account — locked Passkey QA bundle handoff (2026-11-24)

## Scope and current state
**STAGING ONLY — no login activation, no Production changes.** The source reviewed for this build is commit `2ac41e90aafc236edbb79a40cf0b8e352f319636` on `feedback-appeal-release-track`, PR #16 (Draft). The build output is the artifact **asc-passkey-qa-bundle** from GitHub Actions run [45373096741](https://github.com/White-rbx/HealthBar-Remake/actions/runs/45373096741), artifact ID `14909836687` (7-day retention, expires 2026-12-01). Separate Stage 16.80 offline workflow [45373096842](https://github.com/White-rbx/HealthBar-Remake/actions/runs/45373096842) also passed.

Independent local inspection of the downloaded CI artifact verified:

- ZIP size: `165523` bytes; SHA-256: `291707db8518abce8a937e592c008fe9dab6459aa32be9cbda85fada4c283877` (matches GitHub artifact digest).
- Compiled module: `dist/account-passkey-worker.mjs`, `900711` bytes; SHA-256: `d58ea8031e31c8561af8b6721491483c4f403ce28402f63e6f18c4cfeaa18776`.
- `node --check` on the compiled module succeeded with Node.js 22.16.0.
- Bundle contains `dist/account-passkey-worker.mjs` and `package-lock.json`, **not** secrets or account credentials.

As of the read-only Cloudflare check on 2026-11-24, the account QA script `arcscriptcenter-account-qa` is still using deployed version `6b9420db-381c-4d53-8692-a82b76399b52`, with `ASC_ACCOUNT_MODE=isolated-qa`, dedicated D1 `93d7dc3d-c196-40ee-a342-4144f0b85d50`, Rate Limiter, Turnstile secret and key, and encrypted TOTP secret. **Neither** `ASC_ACCOUNT_AUTH_MODE` **nor** `ASC_ACCOUNT_LAUNCH_STATE` is configured. Isolated QA D1 has **0** Account users. The reviewed bundled Passkey code has **not** been uploaded or deployed to the live account QA script by this handoff.

## Next gates — in order

1. **Immutable artifact QA:** verify the downloaded ZIP digest above, the compiled Worker SHA-256, package lockfile, and exact source commit, rather than rebuilding from a moving branch.
2. **No-traffic Workers Version upload:** only to the existing Account QA script and only via the Cloudflare API **version upload** endpoint (not PUT scripts auto-deploy). Use an exact-reviewed module and version metadata. Keep the existing version at 100% deployed traffic and the candidate at 0%. Preserve the exact six bindings and compatibility settings; do not touch other scripts or D1.
3. **Verify no deploy:** re-read `/workers/scripts/arcscriptcenter-account-qa/deployments` and the existing QA public `/health` endpoint. It must still report provisioning/fail-closed; an undeployed version does **not** prove that Passkey endpoints work on the live edge.
4. **Runtime isolated staging test:** validate both recovery and backup WebAuthn flows with **synthetic-only test credentials** on an isolated, publicly unreachable or access-controlled QA target, before any sign-up activation. Explicitly test replay, concurrent recovery, rate limiting, Turnstile origin/action, cookie scopes, session revocation, invalid/expired credentials, and the Workers Free resource limit. Do not reuse Production D1, cases or identities.
5. **Controlled mobile acceptance:** on a supported Android browser, after explicit QA rollout approval and the safeguards above, test registration and backup Passkey, recovery-code rotation, web session and pairing to ESLogin, X cancellation, Remember/rejoin, ban/Restricted Mode and owner-scoped cases. Verify no false Roblox identity assurance. User-facing account enrollment must stay disabled until this gate.

## Rollout safety

- `ASC_ACCOUNT_LAUNCH_STATE` remains **unset**. If required after full validation, only `isolated-test-enabled` explicitly enables QA and must be paired with `ASC_ACCOUNT_AUTH_MODE=passkey`. Never enable `legacy-password-qa` on Workers Free.
- No password KDF iteration reduction, no personal password collection, no raw recovery-code logs, no direct exposure of Cloudflare Worker secret values.
- `ESLogin.lua`, its Close X, and the default ExperienceSettings Loader remain unchanged. PR #16 remains Draft; Production is excluded.
- In an unexpected deployment or service regression, return to the previously verified QA Worker deployment/version and keep the launch flags absent. Do not touch Production or an unrelated Worker.
