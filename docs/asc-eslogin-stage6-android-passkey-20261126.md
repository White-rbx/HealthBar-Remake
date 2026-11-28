# ESLogin Stage 6 — protected Android QA observations (2026-11-26)

**Scope:** STAGING-only `arcscriptcenter-eslogin-edge-qa`, GitHub PR #16 Draft. No Production change, no public Allow Everyone, no credential disclosure.

## What was verified

- Protected Android Chrome website loaded on the actual device through Cloudflare Access; staging account website's Login, Sign In and MyAccount shells were displayed.
- Real Android credential creation prompted for a Passkey; after device approval the website displayed **Passkey registered.** and MyAccount.
- Cloudflare isolated synthetic D1 aggregate after registration: **1 account, 1 passkey, 1 active web session, 8 recovery-code records**, foreign-key violations 0. No recovery code values were queried or recorded.
- The tester confirmed signing out and signing back in using the real Passkey. Aggregate D1 session history then showed multiple web sessions, including revoked sessions and a current session, consistent with the reported logout/login cycle. This is **live Android Login PASS** by observed client outcome and aggregate storage.
- Backup Passkey with the **same Google/Android authenticator** returned the expected native WebAuthn error indicating the credential is already registered for the relying party. No second independent authenticator is available. The normal WebAuthn exclusion policy is retained. **Real Backup PASS is not claimed.**
- Real Recovery was **not performed**: it revokes existing authenticators/sessions and replaces recovery codes. Only disconnected Chromium virtual-authenticator integration tests cover successful Recovery. **Real Recovery PASS is not claimed.**

## Duplicate backup error UX fix

- GitHub branch: `feedback-appeal-release-track`.
- GitHub commit: `a17350e9863cf667d6559cb4de0251fe079ec7f7`.
- `sandbox/asc-account/passkey-client.js` and bundled source `.txt` now translate native duplicate-backup `InvalidStateError` into actionable, non-sensitive UI copy while preserving the original WebAuthn exclusion and backend behavior.
- `sandbox/asc-account/login-pages.test.mjs` verifies no `passkey/backup/verify` request is sent after this browser-side failure.
- GitHub Actions consolidated CI: `45727947314` **SUCCESS**; Stage 16.80 offline QA: `45727947315` **SUCCESS**.

## Current Cloudflare snapshot

- Independent ESLogin STAGING Worker **Version 10**: `d615ff9c-7631-499e-9031-b1b2ca2b96d5`, 100% traffic.
- Version 10 is a narrow replacement of the two client-source spans inside the checked Version 9 Worker bundle. Eight bindings, including QA-only D1, rate limiter, secret bindings and Passkey launch flags, remain intact.
- Emergency rollback target is Version 9 `10dd5161-b452-46fc-a6c2-53f28437a79c`.
- Cloudflare Access remains a single **Allow Email** identity on the independent Worker, with no Everyone allow and no OPTIONS bypass. The tester's email is intentionally omitted from this public report.
- Original Account QA Worker remains Version 10 `6b9420db-381c-4d53-8692-a82b76399b52` at 100% traffic; Production unchanged.
- Latest read-only D1 aggregate: **1 account, 1 registered Passkey, 8 recovery-code records, 0 currently active web sessions**; foreign-key violations 0. Do not infer an authentication failure from the lack of a currently live session; it may expire or have been signed out.

## Outstanding gates

- **Stage 6 is PARTIAL, NOT CLOSED:** Backup on an independent authenticator remains blocked by device availability; live Recovery remains untested. Do not delete the original Passkey or consume recovery codes solely to force a PASS.
- Proceed with non-destructive Stage 7 Roblox ESLogin/Loader work only under the existing Access boundary. The browser and Roblox HTTP client have independent Access authentication. Never copy browser Access cookies into Roblox, share an Access service credential, or bypass the policy.
- PR #16 must remain Draft; do not merge, activate original QA V11, or treat STAGING as Production.
