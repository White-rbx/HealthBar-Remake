# Banned Check Center critical fix

## Reproduced causes

- Edit of a Legacy row put an empty value into the required Ban Selection
  field. The browser rejected the form before sending a request. The scoped
  v2 endpoint also rejected an attempt to retain the Legacy selection. The
  new form restores the stored selection, and the endpoint will retain the
  Legacy marker only on a row that was already Legacy. Its effective mode
  stays Ban in-game.
- Save and Remove used the browser's native `window.confirm()`. In the
  isolated embedded browser test where native dialogs were unavailable, the
  original Remove left the record intact. The new in-page Review/Confirm
  controls support Cancel and send the selected record and its original
  revision after an explicit click. This reproduced the code path without
  assuming what dialog settings or credentials the owner used on their phone.
- The previous UI accepted response data from the same POST and did not
  independently look up the saved result. The fixed UI reads the list again
  and explicitly compares all editable fields or checks that the removed
  ID is absent. If the write or readback is uncertain, the UI asks for a new
  load before a retry. If the server list changed while an edit was open,
  reselect the record before saving.
- Active QA and GitHub-managed bans use separate stores. The Preview remains
  scoped to the existing isolated D1 and authorized test IDs. Bad key,
  disallowed origin, out-of-scope ID, stale revision and unavailable auth or
  storage have distinct failure paths. GitHub-managed writing is not enabled.

## Verification

- Browser with the original and patched form served against a disposable
  Cloudflare Worker and D1. Old Legacy selection was empty/invalid. New Create
  and Legacy Edit persisted after server reload. Cancel kept the record;
  confirmed Remove was independently absent after a fresh HTTP GET.
- Independent Worker/D1 HTTP tests covered all four Selection/Duration
  combinations, invalid key, CORS, missing confirmation, concurrent edit
  and stale SHA, server unavailable, real-time expiration and an expired
  record edit. Fresh Roblox policy requests reported clear after removal
  and after expiry. This tests the server behavior needed for Rejoin but
  does not exercise Roblox itself.
- Setup, Loader main, the server bridge, and Arcsen compiled with Luau.
  Existing Feedback and Case Token routes stayed on the active STAGING
  Worker. The locked live Preview uses the real Admin authentication path;
  owner acceptance with a valid existing key is still a private check.

## Deployment and rollback

| Resource | New rollout | Rollback |
| --- | --- | --- |
| STAGING Pages Preview `stage16-54-verified-unlock` | `b98bf3f2-b2f2-4a6b-a0c2-2cb866f8aefb` | Rebuild the previous addon at commit `2a0275dc` with the same pinned HTML/logo manifest and redeploy the Preview branch. Prior Preview `18f0776f-e9b8-44ed-a777-01e5de608e92` is the content baseline. |
| `arcscriptcenter-ban-v2-qa` | version `2e7c1acb-aae3-4bd6-be70-68fdef10f033`, deployment `ae29c22c-eb02-426e-856c-c8cccae51fa1` | Reassign QA traffic to `4dbda4a9-97c7-4dc3-8a40-1eb944020e4a`. The D1 binding and schema are the same and existing entries are preserved. |

Active canonical STAGING Worker `78d736e3-4bde-4031-8a0b-38c4bd4e6888` and
Production remain out of the rollout. The new canonical STAGING Candidate
is represented in PR source. A version refresh was not accepted by the
connector, so do not use the earlier 0% traffic candidate for these fixes.
Before enabling GitHub-managed storage, validate backend compatibility and
the isolated GitHub write path with proper authorization.

## Roblox acceptance after configuring the authorized test environment

Use the existing test-only server bridge and authorized Roblox test
accounts, then test create/edit/remove while leaving and rejoining Roblox.
Confirm that Ban in-game stops at SetUp and Restricted Mode reaches Loader
main with the correct tool state. Check expiry and unavailable policy,
plus Violation/Appeal and Remember Token. Do not use real ban records or
paste the Admin Key or bridge secret into chat.
