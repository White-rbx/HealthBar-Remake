# ESLogin — Independent HTTPS QA Edge + D1 Capacity Audit (2026-11-25)

**STAGING ONLY. No real enrollment or Login, no database changes, no PR merge, no Account QA Version 11 traffic.**

## Why this route exists

Cloudflare's `arcscriptcenter-account-qa` has Version 10 at 100% deployed traffic and Version 11 uploaded at 0%. Its locked `eslogin` Worker Preview cannot expose a Preview URL while `previews_enabled=false`; turning that flag on also exposes the existing Worker's version URLs, which is not an acceptable isolation workaround.

To test the actual Cloudflare Access edge without exposing Version 11 or consuming D1 capacity, a **separate**, provisioning-only Worker was created. This is deliberately *not* a deployment of the Passkey candidate or a live session service.

## New independent QA Worker

| Item | Verified value |
| --- | --- |
| Worker | `arcscriptcenter-eslogin-edge-qa` |
| Cloudflare Worker tag / ID | `45dc479f0856439bb004c31dc6a48642` |
| Exact HTTPS origin | `https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev` |
| Source | `sandbox/asc-account/eslogin-independent-edge-qa.mjs` plus `provisioning-worker.mjs` |
| Bindings | **0** (no D1, rate-limit token, Turnstile secrets, auth-mode settings or session storage) |
| Subdomain setting | `enabled=true`, `previews_enabled=false` |
| Access app | `ESLogin Independent HTTPS QA - LOCKED`, ID `ea0346cb-02fb-44dc-a5dd-5ada7c60977f` |
| Access destination | Exactly one `worker` target, Worker ID `45dc479f0856439bb004c31dc6a48642`, no path overrides |
| Access policy | `ESLogin Independent HTTPS QA - DENY ALL`, ID `d770fece-7fae-4654-b858-4aba401e3339`, decision `deny` with Include Everyone |
| Account QA Worker | Unchanged, Version 10 receives 100% traffic; its `previews_enabled` remains false |
| Existing locked `eslogin` Preview | Unchanged, no publicly enabled URL; still uses its own `preview_worker` Access app |

The code returns a static Provisioning page or HTTP 503 on all account APIs. It ignores all bindings, cannot read a D1 database and cannot create a session. Its fixed origin is never learned from incoming Host or Origin.

## Live edge smoke

- `sandbox/asc-account/eslogin-independent-edge-qa.test.mjs` verifies fail-closed provisioning behavior, denied cross-origin requests, and that even synthetic authentication flags have no effect.
- `sandbox/asc-account/eslogin-edge-live-access.test.mjs` sends **unauthenticated GET /** and **POST /api/v1/accounts/passkey/login/options** via the public HTTPS hostname, with redirects disabled and no cookies, secrets, identity claims or user data.
- An HTTP 200 landing or 503 from the Provisioning handler is treated as a failed Access boundary. Expected anonymous outcomes are Access challenge/denial statuses 302/303/307/308/401/403.
- The consolidated PR workflow runs both; verify the actual GitHub Actions result and log details before asserting Edge-denial proof. This test does **not** validate Access on the separate, non-routable `eslogin` Preview.

## D1 inventory, read-only (no user records read)

Cloudflare account lists **10 D1 databases**. Querying `sqlite_master` and aggregate `COUNT(*)` for the three databases without direct bindings in any of the **12 existing Worker scripts** found:

| D1 | User table count checked | Total stored rows | Current direct Worker bindings |
| --- | ---: | ---: | --- |
| `asc-feedback-release-qa-20261117` | 7 | **0** | None found |
| `asc-stage1658-prodlike-20261115` | 33 | 12 | None found |
| `asc-prod-backup-restore-20261117` | 22 | 2,626 | None found |

This inventory omits SQLite internal tables. Historical Preview deployments, CI workflows or manual QA may still refer to an unbound database; **no binding** does not prove **safe to delete**. The restore database contains real snapshot data and **must not be deleted** as a way to make room.

`asc-feedback-release-qa-20261117` is the best *candidate for owner review*, not a deletion decision. The project report `docs/feedback-isolated-worker-runtime-qa-pass-20261117.md` states it once held seven synthetic rate-window rows, all removed after its integration smoke, and recorded `quick_check=ok`. Today's read-only query confirms 0 rows in all 7 tables. Verify no active QA workflows, scheduled jobs, unpublished branches, or human restoration requirements remain **before** requesting explicit permission to retire it.

## Current decision gate

**Do not delete or repurpose any D1 without explicit owner authorization.** A new account with separate free D1 capacity is another option, but would require separate credentials, reviewed Cloudflare Access and a new fixed WebAuthn Origin/RP ID. None was connected in the current account inventory.

Authenticated Passkey enrollment, ESLogin pairing, real device acceptance and any change to Access policy remain **BLOCKED** pending an isolated D1 and a reviewed authorization to allow synthetic testers. The independent QA Worker remains `DENY Everyone` until all prerequisites are satisfied.

## Source and actions

- Repo: `White-rbx/HealthBar-Remake` branch `feedback-appeal-release-track`; PR #16 remains Draft.
- GitHub modules: `sandbox/asc-account/eslogin-independent-edge-qa.mjs`, `sandbox/asc-account/eslogin-independent-edge-qa.test.mjs`, `sandbox/asc-account/eslogin-edge-live-access.test.mjs`.
- CI: `.github/workflows/feedback-appeal-release-track.yml`.
- No changes made to existing ten D1 databases, production Worker, Account QA Version 10/11, or previous Preview bindings.
