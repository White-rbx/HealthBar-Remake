# ArcScriptCenter — Stage 16.79: Feedback & Violation Reorganization

Date: 2026-11-17 (Asia/Bangkok)
Status: **Arcsen UIs 7.3.43 client artifact + unified patch generated; static tests passed. Roblox runtime QA and trusted Roblox identity integration are pending.**
Scope: STAGING UI only. **Production NO-GO. Cloudflare Workers/D1 NOT modified or deployed.**

## User-requested hierarchy

Settings → ArcScriptCenter → Feedback & Appeal:
- Rules
- Feedback (nested Feedback Draft, Review, Approved, Denied, Check Existing Case)
- Violation (**conditionally visible only for a Roblox account with authenticated violation history**)
  - Review
  - Approved
  - Denied
  - History

Appeal remains inside the custom Violation notice; it must **not** become a separate top-level category. Admin-only Spam Mail remains outside the normal user's Feedback/Violation page.

## Violation status display and layout

The Violation subcategories use Roblox UIListLayout / LayoutOrder. Each authenticated notice's status determines its **actual notice/card LayoutOrder**:

| Violation status | Color | LayoutOrder | Section |
| --- | --- | --- | --- |
| Not appealed yet (`not_appealed`) | Blue | 0 | Review |
| Appeal submitted, still reviewing (`reviewing`) | Orange | 1 | Review |
| Denied (`denied`) | Red | 2 | Denied |
| Approved (`approved`) | Green | 3 | Approved |

Approved also colors the **Violation category/tab green**, hides/disables the Appeal action and prevents a repeat Appeal for that case. Reviewing is non-repeatable. A Denied case is re-appealable **only if the trusted backend explicitly permits it**, never from client state alone.

No authenticated history → **no Violation category/tab**, not an empty tab and not an auto-open notice. The preserved custom violation viewport is **350 px high**, with Appeal nested under the notice. History must be verified server data; never invent it.

## Feedback status groups

Review/Approved/Denied are inside Feedback (no longer top-level). The existing receipt-protected STAGING **Check Existing Case** remains, now nested under Feedback. Its successful authenticated status lookup updates the corresponding Feedback status group. No account-wide case listing is fabricated: a receipt authenticates access to one case, **not Roblox account identity**.

## Cloudflare inspection — read only

- Existing STAGING Worker: `arcscriptcenter-api-staging`.
- Existing STAGING D1: `arcscriptcenter-staging`.
- Existing tables include `asc_feedback_cases`, `asc_feedback_history` and `asc_violation_notices`.
- The observed `asc_violation_notices` schema contains a `claimed_user_id`; that alone is **not** trusted proof of who is using Arcsen.
- The current signed UI policy has `identityVerified=false`; the client must **not** display a Violation notice from that advisory policy or a spoofable LocalPlayer claim.
- No Cloudflare database writes, migrations, or Worker deployments performed for this stage.

## Staging client artifact

The original v7.3.42 Lua was available in ChatGPT Library; a new full client `Arcsen_v7.3.43_Stage16.79_Feedback_Violation_STAGING.lua` and a unified `.patch` were generated in the chat artifacts. These are **not** in the GitHub repository itself. This branch holds the status reference and implementation/QA record, and must not be mistaken for a deployed client update.

The patch applies cleanly to v7.3.42 and reproduced the v7.3.43 output exactly in static tests. The following passed: Feedback nesting, Violation four subcategories, UIListLayout sorting, blue/orange/red/green orders 0/1/2/3, Approved duplicate-appeal lock, hidden-unverified category, retained 350px custom notice, and unchanged STAGING endpoint.

## Remaining acceptance tests (NOT YET PASSED IN ROBLOX)

1. On mobile, no verified violation → no Violation tab and no false notice.
2. Expand Feedback → Draft / Review / Approved / Denied / Check Existing Case; scroll, open/collapse and check CanvasSize clipping.
3. Validate receipt-authenticated feedback in Reviewing, Approved and Denied groups, including invalid receipt failure.
4. After real server-bound identity attestation is implemented in isolated Sandbox: verify Violation visibility, Review/Approved/Denied/History routing, status colors/layout, and the custom 350px Notice + Appeal.
5. Approved violation → green tab; existing approved case cannot Appeal again (server must reject duplicate even if UI is manipulated).
6. Verify that a forged claimedUserId or locally set identityVerified never reveals a different user's history.
7. No change to Production Worker, D1, routes, credentials or permissions.

**Do not claim live account-based violation history works until the trusted backend integration exists and passes E2E tests.**
