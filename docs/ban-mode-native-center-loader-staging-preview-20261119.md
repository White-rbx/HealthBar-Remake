# ArcScriptCenter — Ban Selection/Duration: native Banned Check Center + Loader routing (2026-11-19)

## Status

**STAGING PREVIEW ONLY.** Native Pages UI is deployed to the existing noncanonical `stage16-54-verified-unlock` Preview and passed live HTTP smoke. New Lua scripts are committed **only** to PR #16 sandbox review files and have passed static contract checks; they have NOT replaced actual running Roblox Loader/SetUp/Arcsen scripts. The backend managed ban schema is still v1 and STAGING Admin Ban POST is intentionally read-only; new selections are **NOT persisted yet**. Production unchanged.

## What the user requested

1. Add explicit `Ban Selection` to existing **Banned Check Center**, not a duplicate moderation page.
2. Keep independent `Ban Duration` with Temporary and Permanent for **either** Selection.
3. `Ban in-game` => `ExperienceSettings-SetUp` only, Loader main blocked.
4. `Restricted Mode` => SetUp gate finishes normally then **Loader main runs** with blocked tools/chat. Preserve Open/Close, About, Arcsen -> Settings -> ArcScriptCenter -> Feedback & Appeal, including trusted Violation/Appeal.
5. Show each managed ban's **Selection and Duration** beside the user in Banned Check Center. For legacy records missing Selection, display **Selection not set (legacy: SetUp-only)** rather than guessing a restricted choice.

## Native Banned Check Center Preview

- Canonical original UI has `#page-bans`, `#banEditorForm`, `#banRecords`, `#banAdminKey`, `#banStart`, `#banEnd`, `#banSave`. Original inline script calls `banRender` with `banState.entries` and sends GitHub-managed ban records.
- New first-party JS adds `#banSelection` options (Ban in-game / Restricted Mode) and `#banDuration` options (Temporary / Permanent). These do **not** imply each other's values. Native expiration input follows Duration; users can still input schedules in ICT as before.
- Each existing managed ban card displays `Selection: … | Duration: …` using authenticated GET `/api/v1/admin/bans` through the existing Ban Center Admin Key; no separate login, no new storage, no logging of Admin Key. Legacy selection shows `Selection not set (legacy: SetUp-only)`, and Duration derives from expiresAt.
- Existing staging API `adminBans` only supports **GET**. New addon intercepts native ban form submit and explicitly says **no changes are saved**. It MUST NOT pretend a mode selection has persisted; do not remove this guard until a reviewed v2 Admin POST supports and validates both Selection and Duration.
- Files: `sandbox/ban-check-center-selection-preview.js`, `sandbox/pages-native-ban-center-mode-preview-20261119.js`, and static/live tests `sandbox/ban-center-selection-preview.test.mjs`, `sandbox/ban-center-mode-live-preview-http.test.mjs`.
- Live Preview: https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/#bans
- Deployment ID: `815b9354-fe25-4aa2-8d36-672e258e471c`, Preview branch `stage16-54-verified-unlock`. Exact original canonical `/index.html` and `/acs-logo.png` asset hashes retained. Initial Preview used manifest keys without leading slashes and its logo returned 404; redeployed with leading-slash paths. **GitHub Actions [44421050335](https://github.com/White-rbx/HealthBar-Remake/actions/runs/44421050335) attempt 2 SUCCESS**: HTML/JS/CSS presence, original User's Case, original logo PNG, POST addon path denied.
- Original STAGING canonical Pages remains `3a36ea6d-d867-45a0-931d-87f6df64ed8c`; original API Worker remains `666d7be4-78ea-43ee-9f63-92e5faac38b6`.

## Loader / SetUp / Arcsen staging source routing

Source paths checked against actual GitHub `loadstring/ExperienceSettings-SetUp.lua`, `loadstring/Loader.lua`, `ExperienceSettings-(loadstring)/Loader.lua` and `loadstring/Arcsen.lua`. No invented name/path, no Production writes.

- `sandbox/ExperienceSettings-SetUp-BanMode-STAGING.lua`: managed bans carry optional `selection` and `duration`, independent. Legacy entries default to SetUp-only for enforcement but are marked `SelectionAssigned=false` for display. `__ES_BANNED=true` only for Ban in-game, `__ES_RESTRICTED_MODE=true` for Restricted Mode, `__ES_BAN_SELECTION` and `__ES_BAN_DURATION` set explicitly. Restricted users proceed with normal SetUp splash completion and Loader gate; Ban in-game stops at SetUp with Type and Duration text.
- `sandbox/Loader-Main-BanMode-STAGING.lua`: stages the reviewed Setup and Loader UI sources and checks restrictive flags. Restricted Mode **passes the Main Loader's SetUp completed gate**, skips RecommendedScript/Editor/Search, loads a restricted Arcsen staging copy, and activates the TopBar UI guard **before** loading Arcsen. Inconsistent mode flags or failed guard cause fail-closed UI. Existing secondary local legacy ban check must not override an explicit managed Restricted selection.
- `sandbox/Loader-UI-BanMode-STAGING.lua`: preserves completion gates, allows only consistent Restricted flag through, blocks Ban in-game.
- `sandbox/Arcsen-BanMode-STAGING.lua`: current 7.3.51 base with `__ES_RESTRICTED_MODE` added to PolicyReadOnly state; SendButton click and re-render are blocked; Chat/New Chat/UI hidden; Settings/Feedback/Appeal remain available. It does not manufacture account-bound Violation data when identityVerified is false.
- `sandbox/RestrictedMode-Topbar-STAGING.lua`: locks all TopBar buttons but Open/Close, About and Arcsen, using real current button name `z8_ChatGPT` (supports future `z8_Arcsen`); retains and restores original button properties, handles added buttons.
- `sandbox/ban-mode-staging-loader-integration.test.mjs`: static checks of all four Lua script boundaries and no real secrets. **It is not a Roblox runtime test.**

## Remaining release gates

1. **Backend schema v2**: Current managed ban JSON `schema:1` and production-compatible Worker validation only allow `userId,username,reason,description,startAt,expiresAt`. Add `selection` and `duration` with strict enum and independent validation in original Worker, any GitHub segment reader/writer, Admin Ban POST, Setup Lua, and versioned migration. Do not automatically convert legacy selection to restricted. STAGING Admin POST must remain read-only until explicit rollout.
2. **Authenticated Roblox QA**: Verify that Ban in-game stops at SetUp and Restricted Mode reaches Loader main; verify TopBar, Arcsen Settings and Appeal, and expiration for both selections. Use synthetic test accounts, not real users.
3. **Server-side enforcement**: `getgenv().__ES_RESTRICTED_MODE`, client UserId and signed UI hints do NOT prove Roblox account ownership or authorize a restriction. Need independent server-verified Roblox principal and per-request API policy checks. Client-side Luau is only UX.
4. Manual acceptance on Preview, then reviewed STAGING canonical promotion. Production release only after approval. PR #16 remains Draft.

## Read-only data verification

At final audit: **7 STAGING Feedback cases, 3 unknown UserId, 0 removed, 0 in Trash**. No real managed ban was changed, no D1 mutation and no Production change. The hourly Trash Cron remains separate.


## Real LoaderMainPreview correction (2026-11-19)

An earlier 239-line fake PlayerGui fixture called `sandbox/LoaderMainPreview.lua` was **replaced**, at the owner's request, with a **full actual Loader.lua-derived entrypoint**. This is NOT a mock UI. The original source comes from `loadstring/Loader.lua` (Git blob `9d6af20cf93610adf9be2e49bf61edabe8903f38`, 1,665 lines); the reviewed `sandbox/Loader-Main-BanMode-STAGING.lua` differs in 10 focused edit regions for routing Ban Selection/Duration and staging dependencies. The executable preview is `sandbox/LoaderMainPreview.lua` (about 1,712 lines).

- Start exactly that preview entrypoint in an **owner-authorized Roblox STAGING/test environment** rather than running the canonical production `loadstring/Loader.lua` as a test. There is no automatic production installation.
- The real Loader Main boot sequence remains: SetUp → readiness/scanning → SetUp screen closes → Get Load/Always Load gate → Main GUI → Arcsen and optional tools.
- Ban in-game uses only the staged SetUp restriction gate. Restricted Mode passes SetUp and Loader main with the restricted TopBar module, staged Arcsen read-only UI, and Editor/Search/RecommendedScript skipped.
- The preview scans its **own** `LoaderMainPreview.lua` path rather than an unrelated UI Loader. Both unrestricted and Restricted routes use the STAGING Arcsen file in Preview, not live Arcsen.
- It uses STAGING Lua source paths on PR branch `feedback-appeal-release-track`; no Production GitHub file/Worker/D1 is overwritten. The preview is **not synthetic**: it may read the existing GitHub-managed ban source. Run with isolated QA identities only, not actual moderation cases.
- The attached CI test `sandbox/loader-main-preview.test.mjs` verifies exact derivation from the reviewed BanMode Loader with only two preview-specific changes, boot/GUI invariants and staging URL routing. It is **static/source QA**. No claim of Roblox client runtime QA, validated account ownership, or server-side restriction enforcement.

**Remaining manual QA:** Check a synthetic unbanned client and separately reviewed Ban in-game/Restricted Mode cases with Temporary/Permanent duration; verify that the real Loader completes, allowed TopBar buttons remain interactive, disallowed tools/chat are inaccessible, Feedback & Appeal remains visible and no unverified Violation is invented. Server enforcement remains a release blocker before any Production rollout.
