# ArcScriptCenter ESLogin — Locked Private Preview preparation (2026-11-25)

**STAGING ONLY. No live authentication, no Worker Preview creation, no D1 write, no Production deploy, and no PR merge.**

## Live read-only inventory

- `arcscriptcenter-account-qa` deployed Worker Version 10 remains at **100% traffic**. Its existing Version 11 Passkey candidate remains uploaded but **not deployed (0%)**.
- The Account QA D1 binding remains pinned to `93d7dc3d-c196-40ee-a342-4144f0b85d50`.
- Connected Cloudflare account lists **10 D1 databases**. None has been approved for replacement/repurposing as a new isolated Preview database.
- Access application listing contains **no app with a `preview_worker` destination for the Account QA Worker**. App name/hostname alone must not count as protection.
- PR #16 remains **Draft**. The legitimate account service is still fail-closed in Provisioning state.

## Implemented GitHub-only candidate and offline tests

- `sandbox/asc-account/private-preview-locked-entry.mjs` exports `validatePrivatePreviewOrigin` and `createLockedPrivatePreview`. It requires a **fixed, exact, HTTPS Preview hostname** under `-arcscriptcenter-account-qa.kogpasan14.workers.dev` and rejects canonical QA host, spoofed host, credentials, arbitrary port, path/query, and wrong Worker names.
- This intentionally **does not export a default deployed Worker**: the real Preview URL has not been provisioned or pinned. The factory ignores authentication settings and does not read D1 or rate-limiter bindings. It serves the existing static Account QA Provisioning response only, including 503 for all account APIs.
- `sandbox/asc-account/private-preview-locked-entry.test.mjs` tests those properties against purely synthetic requests, including hostile account launch flags.
- `sandbox/asc-account/private-preview-gate.mjs` now exports `verifyPreviewAccessDestination(applications)` for Cloudflare Access read-only inventory checks. It requires exactly one self-hosted app for this exact Worker's `preview_worker` destination, no extra destinations and no public path overrides. A successful match **does not** establish that policies are safe or that anonymous edge requests are denied. The result leaves `policiesVerified`, `unauthorizedProbeVerified`, and `readyForLogin` as **false**.
- `private-preview-gate.test.mjs` checks missing/wrong Worker destinations, duplicate apps, extra destinations, and public overrides.
- Both new test sets are in `.github/workflows/asc-account-private-preview-preflight.yml` and the consolidated PR QA workflow. Tests have **no Cloudflare token** and do not mutate remote services.

## Remaining Cloudflare gates (BLOCKED, no automated bypass)

1. Obtain explicitly approved isolated **synthetic-only** D1 capacity for the Preview. Do not attach an existing QA, backup/restore, staging, or Production database as a shortcut.
2. Create and independently verify an Access app with a **`preview_worker` destination for only the Account QA Worker** and a narrow, reviewed allow policy. Verify that an unauthenticated Preview HTTP request is denied **at the edge**, rather than relying on fixture flags.
3. Set the exact Preview hostname and fixed WebAuthn expected Origin/RP ID, with test-only Turnstile credentials for the Preview host and both `asc_register`/`asc_recover` actions. Do not derive expected Origin from inbound Host/Origin.
4. Create the **locked** Worker Preview using isolated bindings and verify account endpoints remain 503 and D1 account rows stay zero. Only then request a separate review before enabling synthetic Passkey ceremonies and ESLogin pairing.
5. Test Android browser Passkey flows, pairing, cancellation, Remember/rejoin and Restricted Mode only after the protected synthetic backend succeeds. Keep default Roblox Loader and Production unaffected.

Cloudflare primary references:
- https://developers.cloudflare.com/workers/previews/resources/
- https://developers.cloudflare.com/workers/configuration/cloudflare-access/
- https://developers.cloudflare.com/workers/versions-and-deployments/version-urls/

## Scope of tests

Passing offline tests proves **code-level gates and synthetic response behavior only**. It cannot demonstrate real Access protection, independent D1, real WebAuthn on the edge, or Roblox Mobile acceptance. Do not mark ESLogin production-ready on this basis.
