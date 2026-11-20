# Banned Check Center v2 STAGING integration

## What is ready to use

- [Banned Check Center QA](https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans)
  is a Preview deployment in the existing STAGING Pages project. It replaces
  only the Ban Center addon. It uses the original Admin Unlock field and the
  original STAGING Admin authentication through a Worker service binding.
- **Load QA Bans**, **Save QA Ban**, **Edit** and **Remove** use the new isolated
  D1 binding. Only the reserved synthetic IDs in the integration Worker are
  enabled by default. The fixture contains a v1 Legacy entry. Its effective
  mode remains Ban in-game when first read and after migration to schema v2.
- The original Ban data source stays on its existing route. The separate
  GitHub adapter is fixed to the seed file on `banned-check-center-staging-data`
  and submits the expected blob SHA to GitHub itself. A change adds an audit
  attempt before external I/O. A lost GitHub response requires reloading
  the source to determine whether the change took effect.

## Data flow

1. The Worker validates an explicit Selection, Duration, confirmation, ICT
   dates and the expected SHA before persisting. In the isolated D1 adapter,
   the CAS and audit trigger run in one SQL statement. The source reader
   accepts both schemas and enforces duplicate UserId rejection.
2. The [Loader QA entrypoint](../sandbox/BannedCenterLoaderPreview.lua)
   requires the Roblox server bridge. Its RemoteFunction takes no account
   identifier from the client. The Roblox server constructs the identity
   assertion from `OnServerInvoke`'s player and a server-only scoped secret.
3. SetUp stops Ban in-game before Loader main. Restricted Mode enters Loader
   main with only the approved TopBar paths; Arcsen chat and other tools
   remain gated. The Loader rechecks server state during a session. After a
   confirmed clear, the initially restricted Loader can initialize its
   missing tools and restore the original TopBar. A tighter state detected
   after the full toolset initialized blocks the UI and requires Rejoin.
   Startup and refresh errors never present a cleared state.
4. The policy, entitlement check and verified Violation/Appeal routes check
   the authenticated subject and active policy on the server. Approved
   appeals cannot be submitted again. Notice links must be created by a
   trusted moderation process; unlinked Feedback or user-supplied IDs cannot
   generate a verified history entry. On isolated QA look up Appeal progress
   in Violation. The regular Feedback and Case Token endpoints still use their
   existing STAGING data and Receipt flow.

## Cloudflare changes

| Resource | Verified change |
| --- | --- |
| `arcscriptcenter-ban-v2-qa` | Active version `4dbda4a9-97c7-4dc3-8a40-1eb944020e4a`; prior rollback version `ac920f87-a1ad-4fe4-af0e-b9fe58f95a50`. Legacy QA routes and AUTH_API retained. |
| Isolated D1 | `asc-banned-center-v2-integration-qa-20261120`, UUID `35d7b6fd-3497-4aa9-a371-3e38e243d72d`. Applied the base Feedback, verified notice, audit and QA source migrations only to this binding. Six synthetic audit events retained. Removed the synthetic appeal and reverted the source to its v1 compatibility fixture. Integrity and foreign keys passed. |
| STAGING Pages Preview | Deployment `18f0776f-e9b8-44ed-a777-01e5de608e92` on `stage16-54-verified-unlock`. Uses the original HTML and logo manifest. Immutable rollback source `1a395835-6d4d-4d9a-a559-a8fe36b8567f`. Redeploy its pinned Worker and asset manifest to restore the Preview alias. |
| `arcscriptcenter-api-staging` | Compiled/uploaded version `4f86654f-bc6d-4486-972a-bec723595a96` at zero traffic. Active Phase 5 version remains `78d736e3-4bde-4031-8a0b-38c4bd4e6888`. |
| Production | No deployment, D1 migration or managed-source write. |

## Checks

- Local SQLite: four combinations, old data, starts/expiry, removals, forged
  identity, Feedback Token rejection, access outage, concurrency, no duplicate
  write, GitHub CAS transport contract, the protected features and verified
  Appeal conditions. The full Luau sources compile.
- Live temporary Worker and isolated D1: v1-to-v2 CRUD, 200/409 race, four
  policy results across fresh requests, timing-based expiry, removal,
  unauthorized requests, permission boundary, subject-bound notice,
  submission and Approved repeat rejection. Uses private synthetic QA
  credentials solely for the temporary smoke worker.
- Fresh HTTP requests simulate the server side of Rejoin. Native Roblox
  runtime and positive owner Admin Unlock are separate acceptance checks.

## Before increasing scope

1. Keep GitHub writes limited to the dedicated synthetic branch. The active
   STAGING application has ongoing Feedback traffic and the new GitHub store
   shares its existing token. Confirm the token can write only the intended
   test source path and confirm the GitHub-backed workflow once privately.
2. For the native acceptance pass, an authorized Roblox test universe and
   test IDs are required. Set up `BAN_GAME_SERVER_SECRET` in server-only secret
   storage, set the matching Worker universe and exact QA Test IDs, and install
   [the ServerScriptService bridge](../sandbox/ArcScriptCenterBanBridge.server.lua).
   Do not use a Feedback token as the bridge credential. The shipped bridge
   defaults to the isolated Worker. Its server-side `UseStagingGitHub`
   attribute is for a later authorized rollout to the canonical STAGING API.
3. On Roblox mobile, exercise the four configurations, missing server,
   Leave → Rejoin, confirmed expiry, and accounts with and without an authored
   notice. Validate the green Approved UI, absence of a repeat Appeal, and the
   continued independent Receipt/Remember Token feedback paths.
4. Use the original Admin Unlock privately on the QA page. Confirm
   Save/Edit/Remove on synthetic records and confirm that the old preview can
   load again before considering the canonical rollout. D1 changes for
   verified histories in canonical STAGING, authenticated GitHub-backed
   UI acceptance, and eventual production approval are still separate.

Rollback uses the exact previous Worker traffic version; do not drop the
additive tables on rollback. The live managed Ban file on the older branch
and the Production database are outside this QA rollback.
