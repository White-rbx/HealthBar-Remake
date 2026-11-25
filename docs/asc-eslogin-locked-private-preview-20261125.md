# ESLogin — Account QA locked Preview control-plane update (2026-11-25)

**STAGING ONLY. No live authentication, no public Preview URL, no D1 write, no Production deployment and no PR merge.** This record supersedes the earlier preparation-only statement from the same day.

## Cloudflare resources created with owner consent

Read-only GET verification after creation confirmed:

| Resource | ID / state |
| --- | --- |
| Account QA Worker | `arcscriptcenter-account-qa`, ID `bf038ed7c6fd47c8b227a9a29fcb2d1d` |
| Deployed Worker | Version 10, `6b9420db-381c-4d53-8692-a82b76399b52`, still **100% traffic** |
| Undeployed Passkey candidate | Version 11, `2b34f5cb-0d89-42f0-8fa9-07b96d487d59`, **0% traffic** |
| Access application | `ESLogin Account QA - Private Preview (LOCKED)`, ID `75bf5130-77b0-4add-b59f-0fca6825fe5e` |
| Access destination | Exactly one `preview_worker` entry for the Account QA Worker ID; **not** `worker`, `all_workers` or a public hostname |
| Access policy | `LOCKED QA - deny all`, ID `df26ef29-38c2-4921-95d3-a79071f962a5`; decision `deny`, Include Everyone, no Exclude/Require, no public path overrides |
| Worker Preview | Name `eslogin`, ID `c7bbd14fd43a4e9a87a308fcab659699`, created using `ignore_base_config=true` |
| Locked Preview deployment | ID `fc8f71e9-cf0f-498b-97b3-181ba01f3576`, source modules `main.mjs`, `private-preview-locked-entry.mjs`, `provisioning-worker.mjs` |
| Preview upload bindings | Submitted explicitly as `bindings: []`; no D1, KV, rate limiter, Account secrets or auth launch flags included |
| Worker Preview URLs | `previews_enabled=false`; Preview API returns `urls: []`, so **not publicly reachable** |
| D1 inventory | 10 databases, unchanged. No database was created, deleted, repurposed, migrated or written. |
| Source control | `feedback-appeal-release-track`, PR #16 remains Draft, not merged. |

The locked deployment imports the reviewed Provisioning Worker and calls `createLockedPrivatePreview` with the fixed HTTPS origin `https://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev`. This is a **reserved expected origin**, not an active working link. The handler returns 503 for account APIs and disables registration/login. All origin checks are exact, and the deployment cannot read D1 because it has no declared D1 binding.

**Do not turn on `previews_enabled` as a quick workaround.** On this existing QA Worker that setting also exposes Worker Version URLs. Version 11 uses its uploaded QA resources rather than a separate Preview D1, so exposing its Version URL would undermine the staged isolation boundary. Cloudflare references:
- https://developers.cloudflare.com/workers/versions-and-deployments/version-urls/
- https://developers.cloudflare.com/workers/versions-and-deployments/preview-urls/
- https://developers.cloudflare.com/workers/previews/resources/
- https://developers.cloudflare.com/workers/configuration/cloudflare-access/
- https://developers.cloudflare.com/d1/platform/limits/

## Verification status and remaining gates

1. **Control plane:** PASS for Access destination and Deny Everyone policy on readback; Preview exists and a locked deployment was uploaded; the main Account QA deployment remains Version 10 100%.
2. **Runtime edge denial:** NOT TESTED. Because no Preview URL is enabled, an anonymous HTTP request cannot yet establish Access enforcement at the edge. Access configuration readback is not a substitute.
3. **Authenticated Preview:** BLOCKED. Must obtain a truly separate synthetic-only D1 (10 Free-plan databases is the documented maximum and 10 are currently listed); preserve all existing D1 databases until the owner explicitly approves a safe solution. Authenticated state must have separate rate limiting, QA-only secrets, correct pinned WebAuthn Origin/RP ID, test Turnstile hostname/action, verified Access policies and negative anonymous tests.
4. **Mobile ESLogin acceptance:** BLOCKED until the protected authenticated Preview is ready. Do not register an actual personal account, issue real Passkeys, initiate pairing or claim that login works on the live Edge.
5. **Production:** Out of scope. Do not merge PR #16 or alter the Account QA deployed Version 10 in this phase.

## GitHub tests

- `sandbox/asc-account/private-preview-locked-entry.test.mjs` simulates fixed-origin, Provisioning and disabled account APIs.
- `sandbox/asc-account/private-preview-gate.test.mjs` simulates the observed locked control-plane snapshot, including failure if Access policy changes, `previews_enabled` becomes true, a Preview URL appears, or Version 10 loses 100% traffic.
- `sandbox/asc-account/private-preview-gate.mjs` exports `verifyLockedPreviewControlPlane`, `verifyPreviewAccessDestination`, `verifyNoTrafficBaseline` and `verifyPrivatePreviewPlan`. All are read-only assertions against supplied snapshots; no Cloudflare tokens, background deployments or D1 writes.
- CI runs the offline tests; a green test **does not** establish live edge Access denial or Passkey authentication.

**Decision:** Locked Preview control-plane preparation complete; **NO-GO for activating Preview URLs, real authentication, Passkey enrollment or production** until the independent-resource and edge-protection gates are satisfied.
