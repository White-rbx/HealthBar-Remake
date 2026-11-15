# ArcScriptCenter — Stage 16.68: Access Boundary Review and Release Gate Checklist

Date: 2026-11-15 (Asia/Bangkok)
Status: **Configuration review complete; unauthenticated and disallowed-identity browser tests pending.**
Production: **NO-GO**.

## 1. Stage 16.67 acceptance and cleanup carried forward

User screenshot dated 2026-11-15 approximately 22:37 Asia/Bangkok confirmed **11/11 PASS** for real-key Feedback and Appeal lifecycle and simulated Siteverify outage rejection. This is browser evidence from the authorized tester, not independently replayed by this assistant.

Afterwards, in isolated `asc-stage1658-prodlike-20261115` Sandbox D1 only, exactly two soft-deleted Stage1667 synthetic cases and six linked history records were removed, following DB identity verification and Time Travel bookmark preflight. Confirmed zero remaining Stage1667 cases and zero orphaned feedback history rows. Existing quota rows left unchanged.

## 2. Cloudflare Access configuration review

Access application: `Stage16.63 ArcScriptCenter Sandbox Protected Worker`.
- Type: self-hosted, destination type Worker.
- Session duration: 1 hour.
- App launcher not visible.
- One ordered Access policy: `Stage16.63 - Sandbox Tester Only`, decision **allow**, include selector type **email**.
- No explicit exclude or require clauses in the reviewed policy.
- Protected test page and Worker routes exist in Sandbox code; the user previously confirmed authorized browser access.

The policy check API needs an authorized user ID and returned HTTP 400 (`access.api.error.invalid_user_id`) without one in Stage16.66; no user identity was supplied, and the assistant did not attempt to collect one. An anonymous external URL fetch from the assistant environment was inaccessible, **which is not proof of Access denial**. The configuration review alone does not prove that a logged-out browser or disallowed user is blocked.

## 3. Live browser smoke-test instructions (manual)

Open a clean private/incognito browser window with **no existing Cloudflare Access session** and visit:

`https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1667/integration`

Expected outcome: Cloudflare Access login/challenge (or explicit Access denial) appears before the protected test UI. A logged-out browser seeing the integration test UI directly **would be a failure**, requiring immediate investigation.

Also test with a separate authorized-to-test identity **not** in the Access allow list, if available. Expected: DENIED, no protected UI or API JSON. Do **not** share email addresses, credentials, login cookies, Access JWTs, secrets or identity IDs in GitHub or chat. Do not create extra personal identities just to perform the test.

Afterwards, return to the known allowed identity and verify the protected test page opens normally. Record only pass/fail and whether a login/denial page appeared.

These are pending **user/browser checks**, not automated results.

## 4. Worker version and D1 partition verification

Cloudflare read-only review showed three distinct Worker versions and DB bindings:

| Environment | Worker | Active version ID | D1 |
|---|---|---|---|
| Production | `arcscriptcenter-api` | `298de84d-418c-489c-b133-c549c785f66e` | `arcscriptcenter-db` |
| Staging | `arcscriptcenter-api-staging` | `5b5040fb-6c04-4029-9c53-af15d3dda888` | `arcscriptcenter-staging` |
| Protected Sandbox | `arcscriptcenter-merge-sandbox-1658` | `c23843e8-f6bb-4f2f-a254-cf0424070a67` | `asc-stage1658-prodlike-20261115` |

Each Worker was at 100% of its own deployment and bound to a different D1 ID.

All three D1 databases use the supported production storage subsystem and returned a current **Time Travel bookmark**. These are backup-availability checks, **not independent Production backup recovery certification**.

No Production or Staging Worker deployment, D1 mutation, Time Travel restore or secret value access was performed in Stage16.68 review.

## 5. Release gates and scope

- [x] Sandbox Stage16.64 HTTP contracts: **19/19**, tester-confirmed.
- [x] Sandbox Stage16.66 genuine Turnstile contract: **4/4**, tester-confirmed.
- [x] Sandbox Stage16.67 Feedback/Appeal genuine Turnstile integration: **11/11**, tester-confirmed.
- [x] Stage16.67 synthetic Sandbox record/history cleanup.
- [x] Access application/policy configuration read-only review.
- [x] D1 environment isolation and current Time Travel bookmark availability.
- [x] Synthetic isolated D1 Time Travel rollback drill (Stage16.66).
- [ ] Actual unauthenticated browser Access login/denial outcome.
- [ ] Actual disallowed-identity browser Access denial outcome, if authorized test identity is available.
- [ ] Independent Production D1 export and restore **to a separate isolated environment** with integrity evidence; never restore over live Production for rehearsal.
- [ ] Full Arcsen end-to-end integration and relevant error conditions.
- [ ] Explicit Production release signoff, change control and rollback plan.

Production stays **NO-GO**.

References:
- https://developers.cloudflare.com/cloudflare-one/access-controls/policies/policy-management/
- https://developers.cloudflare.com/d1/reference/time-travel/

## 6. Follow-up read-only Access Worker-binding verification

Cloudflare's Access application has a destination of type `worker` and a concrete internal Worker ID. That ID was resolved through the Cloudflare Workers API and its `name` matched the intended `arcscriptcenter-merge-sandbox-1658` Sandbox Worker exactly. This is stronger evidence than matching the Access application display name alone.

Cloudflare's current Worker-level Access documentation states that protecting a Worker covers every associated domain, including `workers.dev` and configured routes. Reference: https://developers.cloudflare.com/workers/configuration/cloudflare-access/

The Allow policy still has one email-selector policy with 1-hour session duration. No user email addresses, Access credentials or cookie values were accessed for this verification. The integration routes also have Worker-side `ctx.access` guards. **This is a configuration/route wiring check, not independent confirmation that unauthenticated or disallowed browser identities are rejected.**

Attempts to fetch the private page through a generic external web retrieval tool were not supported by that tool; lack of access is **not** counted as a passing authorization test. Live Incognito Access checks remain pending.
