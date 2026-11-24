# ArcScriptCenter Account — locked Passkey QA bundle handoff (2026-11-24)

## Upload verified on 2026-11-24

The pinned bundle was uploaded to **the existing STAGING Account QA Worker only** as Version **11** (`2b34f5cb-0d89-42f0-8fa9-07b96d487d59`). The connected Cloudflare session called the Workers Version API with `deploy=false` and inherited the exact six bindings from the pinned, deployed Version 10. No new API token or GitHub secret was required.

After the upload:

- A separate Version API read returned a 900,711-byte module. Its SHA-256 was `d58ea8031e31c8561af8b6721491483c4f403ce28402f63e6f18c4cfeaa18776`, which matches the artifact below.
- Deployment `4400fc76-f4aa-4e24-98d4-fdca11bcff56` still directs 100% of traffic to Version 10 (`6b9420db-381c-4d53-8692-a82b76399b52`). Version 11 is absent from the deployment, with 0% traffic. Preview URLs are disabled and the candidate exposes no version URL.
- Compatibility settings, Account QA D1, rate limiter, Turnstile and TOTP bindings were verified after upload. Neither launch flag was added. No D1 migrations or credential writes ran against Cloudflare.
- Live `/health` still returned HTTP 503 `provisioning`, with registration and login disabled. The website had no credential form and the Passkey API returned the provisioning response.
- GitHub Actions [45376385691](https://github.com/White-rbx/HealthBar-Remake/actions/runs/45376385691) and [45376385648](https://github.com/White-rbx/HealthBar-Remake/actions/runs/45376385648) passed. A local run against the pinned bundle also passed 20 automated checks using synthetic data. Chromium with virtual WebAuthn devices and local workerd passed registration, sign-in, backup Passkey on a second virtual device, ESLogin pairing, recovery code rotation and revocation of the prior Loader session. The browser used simulated Turnstile and an isolated local D1 store.

The next gate is an explicitly approved, access-controlled, synthetic-only edge test on isolated Account QA resources. Keep this Worker locked and keep Version 11 outside the active deployment until that gate is ready. Roblox Mobile acceptance remains pending.

## Original build and pre-upload state
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


## Additional 0%-traffic upload guard (2026-11-24)

The pinned candidate uploader is now in sandbox/asc-account/qa-undeployed-version-upload.mjs and covered by qa-undeployed-version-upload.test.mjs. The consolidated QA workflow builds the Passkey bundle and runs the exact SHA-256 match plus synthetic API isolation assertions.

The upload helper is intentionally NOT invoked by CI or by a routine push. The default CLI action verifies only the local bundle digest and performs NO remote API operation. It uses a pinned QA Worker ID, isolated Account D1 ID, exact six bindings, and the current 100% deployed QA Worker version. Any mismatch aborts before the upload.

Only an operator with a separately obtained, privately stored, least-privilege Cloudflare API token may deliberately invoke the uploader with both --upload and the environment guard ASC_ALLOW_ACCOUNT_QA_VERSION_UPLOAD=YES_QA_UNDEPLOYED_ONLY. Never put Cloudflare tokens in chat, the repository, Roblox, test fixtures, or logs.

The uploader uses ONLY the beta Workers Version POST endpoint with specific-version inheritance and confirms the previous QA deployment is unchanged. It never calls the Deployment API, never enables ASC_ACCOUNT_AUTH_MODE or ASC_ACCOUNT_LAUNCH_STATE, and cannot alter Production resources.

The four local mock-based uploader tests passed, and CI now includes these checks. The CI-tested build is an upload-ready artifact, NOT evidence that a new Cloudflare version has already been uploaded. At this point the CI handoff had no confirmed cloud upload. See the later Version 11 verification above.

## Locked CI upload attempt — 2026-11-24, GitHub Actions run 45376200157

The first dedicated locked-version workflow ran to completion on commit `18cd9902d3c0e86f1ffb9829e024e8b30cd0051e`:

- `npm install` / bundle compilation completed successfully; immutable module digest verified.
- `qa-undeployed-version-upload.test.mjs`: **4 tests PASS**, 0 failed.
- Offline helper dry run printed `PASS: pinned QA module digest. Offline-only dry run; NO upload.`
- The upload step did **not** call Cloudflare: GitHub Actions logged `No CLOUDFLARE_API_TOKEN secret: upload skipped. No traffic changed.`
- The overall Actions run was marked success because an absent token is a deliberate, safe no-upload path. **Do not misinterpret this green status as a successful Version API upload.**
- Read-only Cloudflare verification after the run still found the existing Account QA deployment pinned to version `6b9420db-381c-4d53-8692-a82b76399b52` at 100%, no `ASC_ACCOUNT_AUTH_MODE` or `ASC_ACCOUNT_LAUNCH_STATE` settings. No account launch.

This earlier workflow is kept as a record of the skipped CI upload. Version 11 was subsequently uploaded through the connected Cloudflare session, as verified above. Version 11 requires no further upload or GitHub token secret.
