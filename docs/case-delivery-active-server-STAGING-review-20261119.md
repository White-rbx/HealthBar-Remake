# ArcScriptCenter — Active Server Case Delivery (STAGING review, 2026-11-19)

## Requested flow

`Client active → Arcsen → Server → Case → Arcsen → Client`

Only an **active Arcsen Feedback & Appeal panel** initiates a request. It is NOT
the existing presence, metrics or "Active User" count. No server push to offline
users; the client periodically polls while open and active, then retrieves the
latest status after rejoin. Does not create new Admin UI or expose internal
session tokens or the owner-link table to the Admin Dashboard.

## What is committed to PR #16

- `sandbox/feedback-case-delivery-staging.mjs`: REVIEW-ONLY Worker handler
  for `POST /api/v1/client/cases/poll` (body `{}`) and
  `POST /api/v1/client/cases/link` (one-time ID + private Receipt).
- `migrations/feedback_case_owner_links_STAGING_REVIEW_ONLY_20261119.sql`:
  **UNAPPLIED** additive D1 owner mapping keyed by case ID with exact
  independently verified OIDC subject. No migration of unverified
  `claimed_user_id` and no changes to real cases.
- `sandbox/feedback-case-delivery-staging.test.mjs`: synthetic tests covering
  spoofed ID, unverified session denial, owner isolation, 404, 429, DB errors,
  receipt linking, polling on rejoin, removed and spam_mail privacy.
- `sandbox/Arcsen-Preview.lua`: an isolated full Arcsen copy with a native
  **Server Case Delivery** subsection inside Feedback & Appeal > Feedback,
  a `Check Server Cases` control and an explicit `Link this case to my
  verified account` form for legacy cases. It runs polling only while the
  Feedback UI is expanded/active (45s existing loop with 60s min interval).
  The polling request sends **no UserId**, no Admin key and no receipt. Link
  requires a private Receipt once and clears that input upon success.
- `sandbox/LoaderMainPreview.lua` is still linked to
  `sandbox/ExperienceSettings-SetUp-Preview.lua` and
  `sandbox/Arcsen-Preview.lua`. Production sources untouched.

## Access-control rules

1. The Worker must get an independently verified Roblox OAuth identity
   from a **server-issued, short-lived, device-specific** session.
   `resolveActivePrincipal(request,env)` is an injected TRUSTED callback that
   MUST validate a server-issued token, verified OAuth subject, expiry, active
   session and the narrowly scoped `cases:read` permission.
2. A raw Client UserId, `claimed_user_id`, Roblox directory lookup, game
   client Boolean, Origin, IP or a bare Authorization header is **not proof**.
3. `checkRateLimit` must be a real independent server-enforced limiter;
   no bypass on DB/unavailable errors. The endpoint has no cacheable data.
4. `link`: subject from verified session + matching 64-hex private Receipt.
   Server compares SHA-256 hash to the original `receipt_hash` and writes one
   link only; it refuses reassignment to a different principal.
5. `poll`: select linked, nonremoved Feedback from private owner mapping.
   Return case ID, kind, topic, public status, public note and revision only.
   Never send Description, Admin notes, receipts, other UserIds or ownership
   data. Case `spam_mail` continues to display as `reviewing`.
6. No `asc_presence_sessions`, no `asc_usage_live_sessions` or Active User
   metrics dependency. Admin has no new route for owner mapping. Infrastructure
   administrators with database access are a separate privileged trust role.

## NOT YET DONE / hard gates

**This is NOT live Case Delivery.** The STAGING Worker still has no mounted
verified Case Delivery routes. The current Stage16.83 browser pairing ceremony
is a sandbox proposal returning only a nonprivileged approval indication;
it does not issue trusted device case-session tokens. Arcsen Preview's
`loc.API.GetVerifiedCaseSessionToken` callback intentionally remains absent
until a reviewed trusted OAuth-device session issuer is built. Therefore the UI
will say "Not linked" and make NO poll/link network requests by default.
Do not set this callback to blindly trust a LocalPlayer UserId or arbitrary
client string. No secret, access token or Admin Key should be committed.

Before integration: independently verify live OIDC identity and explicit
account pairing with phishing-resistant user confirmation, issue/revoke
short-lived device grants, review rate-limiting/trusted origin/ingress, apply
the migration to an **isolated** QA D1, run real Worker runtime security tests,
then separately deploy an approved STAGING candidate. Do not touch Production
until the owner explicitly approves it.

Previously submitted Feedback with only claimed UserId cannot be automatically
linked. The owner must link once with a valid Receipt through an authenticated
session. New submissions can be attached automatically *only after* the
submission path is verifiably account-bound on the Server.

## Rollback and safety

PR #16 remains Draft; this change has no Cloudflare/D1/Admin schema writes.
Rollback is dropping the unmounted candidate routes or reverting the Preview
branch code; data migration is not activated. Do not repeat previous Production
backup/restore attempts as part of this UI-only review.
