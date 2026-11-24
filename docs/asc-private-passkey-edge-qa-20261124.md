# ArcScriptCenter Account — Private Edge Preview preflight (2026-11-24)

**STAGING ONLY. STOP BEFORE LIVE PREVIEW CREATION.** This is a read-only control-plane audit and offline safety gate, not a Passkey runtime acceptance test and not authorization to enroll accounts.

## Verified locked deployment

- Worker: `arcscriptcenter-account-qa`; Worker ID `bf038ed7c6fd47c8b227a9a29fcb2d1d`.
- Deployed Version 10 `6b9420db-381c-4d53-8692-a82b76399b52` remains **100% traffic**.
- Uploaded Version 11 `2b34f5cb-0d89-42f0-8fa9-07b96d487d59`, from the immutable pinned Passkey candidate commit `2ac41e90aafc236edbb79a40cf0b8e352f319636`, remains **0% deployed traffic**.
- Only the existing six QA bindings are present, with `ASC_ACCOUNT_MODE=isolated-qa`. **Both** `ASC_ACCOUNT_AUTH_MODE` and `ASC_ACCOUNT_LAUNCH_STATE` are absent. Do not add them.
- Existing QA D1: `93d7dc3d-c196-40ee-a342-4144f0b85d50`; a read-only SQL check showed **0 accounts, 0 Passkeys, 0 recovery codes, 0 sessions, 0 recovery flows and 0 backup flows**.
- Read-only Cloudflare listing returned **0 Worker Previews for this Worker** and **10 account D1 databases total**. No new D1 or Preview was created. The account-level Access application list has not established a verified `preview_worker` protection policy specific to this Worker.
- PR #16 remains Draft; Production and the default Loader unchanged.

## Critical distinction: Worker Version URL vs Worker Preview

Cloudflare states that a **Version URL** executes a specific uploaded Worker version with that version's existing bindings and resources. It is **not** a separate private test environment. In particular, a Version URL for this Worker would share the existing QA D1 and secrets; do **not** activate sign-ups through that URL.

A **Worker Preview** may have its own variables, secrets and D1 binding, but *does not automatically isolate D1 by name*: a Preview binding to the same D1 ID shares records. Preview URLs are **public by default**. A private QA Preview requires a dedicated, reviewed Cloudflare Access `preview_worker` rule and explicit isolated bindings before exposing an authentication page.

Cloudflare documentation:
- https://developers.cloudflare.com/workers/versions-and-deployments/version-urls/
- https://developers.cloudflare.com/workers/previews/resources/
- https://developers.cloudflare.com/workers/previews/get-started/
- https://developers.cloudflare.com/workers/configuration/cloudflare-access/

## Fixed-origin implementation blocker

The current `sandbox/asc-account/worker.mjs` entrypoint rejects URLs whose origin differs from `https://arcscriptcenter-account-qa.kogpasan14.workers.dev`. Both WebAuthn verification and the RP ID are bound to that exact origin; Turnstile also checks the hostname and action. Thus, the current compiled Version 11 **cannot simply be pointed at a Preview hostname** for full WebAuthn ceremonies: it will fail its origin gate. Do not work around this by trusting an arbitrary inbound Host header or relaxing origin/UV requirements.

A future *separately reviewed Preview entrypoint* must inject an explicitly pinned HTTPS Preview origin into `createAccountWorker({origin})`; the corresponding Turnstile test site/secret must validate that Preview hostname and both `asc_register` and `asc_recover` actions. Keep the original QA and Production entrypoints unchanged.

## Prerequisites before a controlled QA Edge test

1. Arrange a genuinely independent **synthetic-only D1** (schema applied and integrity verified) and rate limiter, separate from both the existing Account QA DB and Production. The account currently lists **10 D1 databases**, so do **not** attempt automatic creation, delete or repurpose any database to evade a quota. An owner-approved inventory audit is required to safely identify a reusable *already isolated* database or other approved capacity.
2. Create and independently verify a Cloudflare Access policy specifically protecting this Worker's Preview routes. Do not rely on URL secrecy or a Boolean value entered into a test fixture. Verify the negative unauthorized request before any real credential ceremony.
3. Review explicit fixed Preview-origin entrypoint, WebAuthn RP ID, and a dedicated Turnstile test configuration. Use generated synthetic-only secrets, separate rate-limiter binding and an isolated account database.
4. Create only the **locked** Preview first: no `ASC_ACCOUNT_AUTH_MODE`, no `ASC_ACCOUNT_LAUNCH_STATE`, no public registration. Test 503/provisioning, 403 origin denial, no account rows, no user data and no effect on Version 10 traffic.
5. After independent staging-owner approval, perform controlled synthetic WebAuthn registration/login, second Passkey, recovery rotation, concurrent recovery, revocation, ESLogin pairing, Remember/rejoin and Android verification. Do not claim real Roblox ownership based solely on an untrusted client UserId.
6. Re-read deployment settings/versions and QA D1 after every major gate; keep Version 10 at 100%, Version 11 at 0% until a separately approved rollout. Never touch Production or merge PR #16 based on offline pass alone.

## Implemented offline guard

`sandbox/asc-account/private-preview-gate.mjs` exports `verifyNoTrafficBaseline()` and `verifyPrivatePreviewPlan()`; it **does not connect to Cloudflare or perform mutations**. `private-preview-gate.test.mjs` has **10 Node.js test groups** that exercise normal and blocked plans, including unsafe Version URL, missing Access, shared D1, changed deployment, unexpected signup, wrong origin, incorrect Turnstile host/action, non-isolated rate limiter and missing synthetic-only secrets.

GitHub Actions workflow `.github/workflows/asc-account-private-preview-preflight.yml` runs these tests with **read-only GitHub contents permission and no Cloudflare token**. Its green result proves **only the offline policy assertions**. Positive test inputs are *synthetic fixtures, not evidence* that the required Preview, Access policy or D1 already exists.

**Decision:** NO-GO for authenticated Edge Preview until the above blockers are independently verified. It is safe to continue offline QA and read-only Cloudflare inspection.
