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

## Final integration verification on November 25

The reserved Preview origin is pinned to `https://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev`. The read-only gate checks the exact origin, DENY Everyone without exceptions or OPTIONS bypass, both empty Preview URL inventories, and the exact deployment serving Version 10 at 100%. The updated gate passed against the actual Cloudflare API snapshot. The downloaded locked entry matched the checked-in executable statements. An anonymous HTTPS request to the reserved Preview returned 404 with no Access redirect. The active Account QA host still reported 503 provisioning and both account launch flags disabled. A routed private Preview is needed to verify Access denial at the edge.

Local synthetic testing used an ephemeral D1 and a separate limiter. Chromium virtual WebAuthn with the latest branch bundle exercised Login, Sign In, MyAccount, registration, sign-in, backup Passkey, ESLogin pairing, replay rejection, expired Loader session rejection and issuance of a fresh session by pairing again. Recovery replaced the old credentials and revoked that Loader session. Luau VM tested X, Remember and Rejoin, timeout without late profile restoration, and local logout when storage deletion or remote revocation fails. The client overwrites a Remember file with an empty object if deletion fails, and warns if neither operation succeeds.

For an authorized live edge test, allocate separate synthetic D1 capacity and choose an isolated route that does not enable Version URLs on this Worker. Verify Access rejects anonymous requests before adding any authentication bindings, then review the scoped test policy and pairing transport. Use a dedicated QA Turnstile widget restricted to the exact authorized hostname. The registration and recovery actions are `asc_register` and `asc_recover`. Cloudflare's dummy validation response does not supply these action and hostname values, so those keys are suitable only for offline fixtures that explicitly simulate Siteverify. The live exact checks stay in place. Use separate rate limiting and QA secrets, and keep all credentials out of the Roblox client.

The account currently lists 10 D1 databases. Cloudflare's Free limit is 10, so a separate database in this account needs owner-approved capacity. A separately authorized QA account with a free slot can also isolate the test if its Worker, origin, Access and credentials are reviewed together. The existing databases, Version 10 traffic, Version 11, Access application and Preview were read-only in this integration pass. Android Passkey and native Roblox Mobile remain pending.
