# ESLogin Mobile Tester ID preview — STAGING ONLY

**Purpose:** Let the configured Roblox tester inspect the restored ESLogin GUI on an owned test experience **without** activating ArcScriptCenter Account QA or trusting an unverified Account identity.

## Authorized tester

- Roblox LocalPlayer UserId: `8728964745` (UI display gate only).
- Entry: `sandbox/ASCAccountTesterPreview.lua`. It opens `sandbox/LoaderMainPreview.lua` with the opt-in argument `account_qa_tester`.
- Before any regular Loader bootstrap, `LoaderMainPreview` delegates to `sandbox/ESLoginTesterPreview.lua` and exits the main Loader.
- `ESLoginTesterPreview.lua` checks `Players.LocalPlayer.UserId`; other users receive a warning and **no UI**. It loads the real `sandbox/ESLogin.lua`, not a new look-alike screen.

## What the tester can verify on a phone

- ESLogin starts with original **Username** and **Password** placeholders (read-only; no password is entered or transmitted).
- Dedicated read-only Pairing Code box and Sign-in Status text do not overwrite the original fields.
- The `Login` button responds and states that this is a tester-only locked QA preview.
- The link to `https://arcscriptcenter-account-qa.kogpasan14.workers.dev/signin` can be copied or opened if the client supports it. **That endpoint is currently LOCKED (503/provisioning)** and is not proof the 3-page `arcscriptcenter-login` website has been deployed.
- The red `X` closes the UI. Closing or finishing the preview never starts the main ExperienceSettings Loader.
- `Remember` is explicitly disabled during this isolated UI preview.

## Security/non-goals

The allowlist checks the **local** Roblox UserId and **must not** be treated as verified identity for Cloudflare, Cases, Ban decisions, sessions, or permissions. Anyone with client control may alter client-side presentation; the server remains responsible for actual authentication. The tester client has no HTTP request transport, `begin()` never creates a pairing, `poll()` fails closed, `refresh()` never returns a profile and `profile()` is always nil.

This path makes **no Cloudflare API call or D1 mutation**. It cannot authenticate and does not lift the registration/login lock. `ASCAccountLoaderPreview.lua` remains the existing actual-account QA entry and is unchanged. The main, default, public and Production entrypoints are unchanged.

## Validation

- `sandbox/loader-main-preview.test.mjs`: checks early routing, Tester ID, no-session and fail-closed contract.
- `sandbox/ban-v2-native-luau.test.mjs`: executes allowlisted and disallowed code paths in Luau VM with synthetic Roblox services and confirms even a simulated successful UI return **cannot** unlock the main loader.
- `.github/workflows/feedback-appeal-release-track.yml`: compiles the new tester files and runs all existing native Luau tests.

**No Public Release, Production deployment, Cloudflare Worker version change, session issuance or PR #16 merge is part of this work.**
